package com.mandarin.vpn;

import android.app.AlertDialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.VpnService;
import android.os.Bundle;
import android.os.RemoteException;
import android.provider.Settings;
import android.util.Log;
import android.widget.Toast;
import android.app.NotificationChannel;
import android.app.NotificationManager;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.multidex.MultiDex;

import com.android.installreferrer.api.InstallReferrerClient;
import com.android.installreferrer.api.InstallReferrerStateListener;
import com.android.installreferrer.api.ReferrerDetails;

import org.json.JSONObject;

import java.io.IOException;
import java.io.StringReader;
import java.util.ArrayList;

import de.blinkt.openvpn.VpnProfile;
import de.blinkt.openvpn.core.ConfigParser;
import de.blinkt.openvpn.core.OpenVPNService;
import de.blinkt.openvpn.core.OpenVPNThread;
import de.blinkt.openvpn.core.ProfileManager;
import de.blinkt.openvpn.core.VPNLaunchHelper;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;


public class MainActivity extends FlutterActivity {
    private MethodChannel vpnControlMethod;
    private MethodChannel vpnControlMethodReferrer;
    private EventChannel vpnControlEvent;
    private EventChannel vpnStatusEvent;
    private NotificationChannel notificationsChannel;
    private EventChannel.EventSink vpnStageSink;
    private EventChannel.EventSink vpnStatusSink;

    private static final String EVENT_CHANNEL_VPN_STAGE = "id.mandarin.vpn/vpnstage";
    private static final String EVENT_CHANNEL_VPN_STATUS = "id.mandarin.vpn/vpnstatus";
    private static final String METHOD_CHANNEL_VPN_CONTROL = "id.mandarin.vpn/vpncontrol";
    private static final String NOTIFICATIONS_CHANNEL = "yandex_metrica_push_v2"; // "id.mandarin.vpn/notifications"; not work
    private static final String REFERRER_CHANNEL = "id.mandarin.vpn/referrerClient";
    private static final int VPN_REQUEST_ID = 1;
    private static final String TAG = "MandarinVPN";

    private VpnProfile vpnProfile;

    private String config = "",
            username = "",
            password = "",
            name = "",
            dns1 = VpnProfile.DEFAULT_DNS1,
            dns2 = VpnProfile.DEFAULT_DNS2;

    private ArrayList<String> bypassPackages;

    private boolean attached = true;

    private JSONObject localJson;

    @Override
    public void finish() {
        vpnControlEvent.setStreamHandler(null);
        vpnControlMethod.setMethodCallHandler(null);
        vpnControlMethodReferrer.setMethodCallHandler(null);
        vpnStatusEvent.setStreamHandler(null);
        super.finish();
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        super.attachBaseContext(newBase);
        MultiDex.install(this);
    }

    @Override
    public void onDetachedFromWindow() {
        attached = false;
        super.onDetachedFromWindow();
    }

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        LocalBroadcastManager.getInstance(this).registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String stage = intent.getStringExtra("state");
                if (stage != null) setStage(stage);

                if (vpnStatusSink != null) {
                    try {
                        String duration = intent.getStringExtra("duration");
                        String lastPacketReceive = intent.getStringExtra("lastPacketReceive");
                        String byteIn = intent.getStringExtra("byteIn");
                        String byteOut = intent.getStringExtra("byteOut");

                        if (duration == null) duration = "00:00:00";
                        if (lastPacketReceive == null) lastPacketReceive = "0";
                        if (byteIn == null) byteIn = " ";
                        if (byteOut == null) byteOut = " ";

                        JSONObject jsonObject = new JSONObject();
                        jsonObject.put("duration", duration);
                        jsonObject.put("last_packet_receive", lastPacketReceive);
                        jsonObject.put("byte_in", byteIn);
                        jsonObject.put("byte_out", byteOut);

                        localJson = jsonObject;

                        if (attached) vpnStatusSink.success(jsonObject.toString());
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }, new IntentFilter("connectionState"));
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        notificationsChannel = new NotificationChannel(NOTIFICATIONS_CHANNEL, "Default", NotificationManager.IMPORTANCE_HIGH);
        NotificationManager notificationManager = getSystemService(NotificationManager.class);
        notificationManager.createNotificationChannel(notificationsChannel);

        vpnControlEvent = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_VPN_STAGE);
        vpnControlEvent.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                vpnStageSink = events;
            }

            @Override
            public void onCancel(Object arguments) {
                vpnStageSink.endOfStream();
            }
        });

        vpnStatusEvent = new EventChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), EVENT_CHANNEL_VPN_STATUS);
        vpnStatusEvent.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object arguments, EventChannel.EventSink events) {
                vpnStatusSink = events;
            }

            @Override
            public void onCancel(Object arguments) {

            }
        });

        vpnControlMethod = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), METHOD_CHANNEL_VPN_CONTROL);
        vpnControlMethod.setMethodCallHandler((call, result) -> {
            switch (call.method) {
                case "stop":
                    OpenVPNThread.stop();
                    setStage("disconnected");
                    break;
                case "start":
                    config = call.argument("config");
                    name = "Mandarin VPN - " +  call.argument("country");
                    username = call.argument("username");
                    password = call.argument("password");

                    if (call.argument("dns1") != null) dns1 = call.argument("dns1");
                    if (call.argument("dns2") != null) dns2 = call.argument("dns2");

                    bypassPackages = call.argument("bypass_packages");

                    if (config == null || name == null) {
                        Log.e(TAG, "Config not valid!");
                        return;
                    }

                    prepareVPN();
                    break;
                case "refresh":
                    updateVPNStages();
                    break;
                case "refresh_status":
                    updateVPNStatus();
                    break;
                case "stage":
                    result.success(OpenVPNService.getStatus());
                    break;
                case "kill_switch":
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                        Intent intent = new Intent(Settings.ACTION_VPN_SETTINGS);
                        startActivity(intent);
                    }
                    break;
            }
        });

        vpnControlMethodReferrer = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), REFERRER_CHANNEL);
        vpnControlMethodReferrer.setMethodCallHandler((call, result) -> {
            InstallReferrerClient referrerClient;
            referrerClient = InstallReferrerClient.newBuilder(this).build();
            referrerClient.startConnection(new InstallReferrerStateListener() {
                @Override
                public void onInstallReferrerSetupFinished(int responseCode) {
                    switch (responseCode) {
                        case InstallReferrerClient.InstallReferrerResponse.OK:
                            ReferrerDetails response = null;
                            try {
                                response = referrerClient.getInstallReferrer();
                            } catch (RemoteException e) {
                                e.printStackTrace();
                            }
                            String referrerUrl = response.getInstallReferrer();
                            result.success(referrerUrl);
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.FEATURE_NOT_SUPPORTED:
                            result.success("FEATURE_NOT_SUPPORTED");
                            break;
                        case InstallReferrerClient.InstallReferrerResponse.SERVICE_UNAVAILABLE:
                            result.success("SERVICE_UNAVAILABLE");
                            break;
                    }
                }

                @Override
                public void onInstallReferrerServiceDisconnected() {}
            });
        });
    }

    private void prepareVPN() {
        if (isConnected()) {
            setStage("prepare");

            try {
                ConfigParser configParser = new ConfigParser();
                configParser.parseConfig(new StringReader(config));
                vpnProfile = configParser.convertProfile();
            } catch (IOException e) {
                e.printStackTrace();
            } catch (ConfigParser.ConfigParseError configParseError) {
                configParseError.printStackTrace();
            }

            Intent vpnIntent = VpnService.prepare(this);
            if (vpnIntent != null) startActivityForResult(vpnIntent, VPN_REQUEST_ID);
            else startVPN();
        } else {
            setStage("nonetwork");
        }
    }

    private void startVPN() {
        try {
            setStage("connecting");

            if (vpnProfile.checkProfile(this) != de.blinkt.openvpn.R.string.no_error_found) {
                throw new RemoteException(getString(vpnProfile.checkProfile(this)));
            }
            vpnProfile.mName = name;
            vpnProfile.mProfileCreator = getPackageName();
            vpnProfile.mUsername = username;
            vpnProfile.mPassword = password;
            vpnProfile.mDNS1 = dns1;
            vpnProfile.mDNS2 = dns2;

            if (dns1 != null && dns2 != null) {
                vpnProfile.mOverrideDNS = true;
            }

            if (bypassPackages != null && bypassPackages.size() > 0) {
                vpnProfile.mAllowedAppsVpn.addAll(bypassPackages);
                vpnProfile.mAllowAppVpnBypass = true;
            }

            ProfileManager.setTemporaryProfile(this, vpnProfile);
            VPNLaunchHelper.startOpenVpn(vpnProfile, this);
        } catch (RemoteException e) {
            setStage("disconnected");
            e.printStackTrace();
        }
    }


    private void updateVPNStages() {
        setStage(OpenVPNService.getStatus());
    }

    private void updateVPNStatus() {
        if (attached) vpnStatusSink.success(localJson.toString());
    }


    private boolean isConnected() {
        ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);
        NetworkInfo nInfo = cm.getActiveNetworkInfo();

        return nInfo != null && nInfo.isConnectedOrConnecting();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == VPN_REQUEST_ID) {
            if (resultCode == RESULT_OK) {
                startVPN();
            } else {
                setStage("denied");
                Toast.makeText(this, "Permission is denied!", Toast.LENGTH_SHORT).show();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }


    private void setStage(String stage) {
        switch (stage.toUpperCase()) {
            case "CONNECTED":
                if (vpnStageSink != null && attached) vpnStageSink.success("connected");
                break;
            case "DISCONNECTED":
                if (vpnStageSink != null && attached) vpnStageSink.success("disconnected");
                break;
            case "WAIT":
                if (vpnStageSink != null && attached) vpnStageSink.success("wait_connection");
                break;
            case "AUTH":
                if (vpnStageSink != null && attached) vpnStageSink.success("authenticating");
                break;
            case "RECONNECTING":
                if (vpnStageSink != null && attached) vpnStageSink.success("reconnect");
                break;
            case "NONETWORK":
                if (vpnStageSink != null && attached) vpnStageSink.success("no_connection");
                break;
            case "CONNECTING":
                if (vpnStageSink != null && attached) vpnStageSink.success("connecting");
                break;
            case "PREPARE":
                if (vpnStageSink != null && attached) vpnStageSink.success("prepare");
                break;
            case "DENIED":
                if (vpnStageSink != null && attached) vpnStageSink.success("denied");
                break;
        }
    }
}