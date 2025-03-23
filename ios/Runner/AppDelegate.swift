import UIKit
import Flutter
import NetworkExtension
import SafariServices
import SwiftyStoreKit
import YandexMobileMetrica
import flutter_vpn

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    var currentManager: NETunnelProviderManager?

    let defaults = UserDefaults.standard

    var subscriptionActive = false

    private var blockerResult: FlutterResult!
    private var initResult: FlutterResult!
    private var restoreResult: FlutterResult!
    private var purchaseResult: FlutterResult!

    override func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: Инициализация менеджера впн
        let vpnManager = NEVPNManager.shared()
        vpnManager.loadFromPreferences { (error) -> Void in
            if error != nil {
                print("VPN Preferences error: 1")
            }
        }
        
        // MARK: Инициализация аппметрики
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "01bda33d-67d4-4ef7-8d90-9f70a6890f57")
        YMMYandexMetrica.activate(with: configuration!)

        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.gsvpn",
                binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in


            switch call.method {
            case "initPurchases":
                self.initResult = result
                self.setupIAP()
            case "restoreProducts":
                self.restoreResult = result
                self.restoreProducts()
            case "purchaseProduct":
                self.purchaseResult = result
                self.purchaseProduct(id: call.arguments as! String)
            case "blockerState":
                self.blockerResult = result
                self.getState()
            case "sendEvent":
                self.sendEvent(name: call.arguments as! String)
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        })
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func sendEvent(name : String){
        YMMYandexMetrica.reportEvent(name, parameters: nil, onFailure: { (error) in
            print("REPORT ERROR")
        })
    }


    func getState() {
        SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: "com.westbridge.gsvpn.Blocker", completionHandler: { (state, error) in
            self.blockerResult(state?.isEnabled)
        })
    }


    func setupIAP() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    self.setSubscriptionState(active: true)
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }

        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap {
                $0.contentURL
            }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
        if defaults.object(forKey: "nextCheck") == nil {
            initResult(false)
            return
        }
        let nextCheckDate: Date = (defaults.object(forKey: "nextCheck") as! Date)
        let todayDate = Date()
        if todayDate > nextCheckDate {
            // MARK: Заменить шаред сикрет
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "e9e451bf8eff4e4ebace13017475ccbc")
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    let productIds = Set(["com.westbridge.gsvpn.weekly", "com.westbridge.gsvpn.monthly", "com.westbridge.gsvpn.annual"])
                    let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        var data = expiryDate
                        data = Calendar.current.date(byAdding: .day, value: 1, to: data)!
                        self.defaults.set(data, forKey: "nextCheck")
                        self.setSubscriptionState(active: true)
                        if self.defaults.bool(forKey: "isTrial") {
                            // BranchEvent.customEvent(withName: "conversionTrial").logEvent() MARK: AM
                            self.defaults.set(false, forKey: "isTrial")
                        } else {
                            //  BranchEvent.standardEvent(.purchase).logEvent()
                        }
                        print("\(productIds) are valid until \(expiryDate)\n\(items)\n")
                    case .expired(let expiryDate, let items):
                        print("\(productIds) are expired since \(expiryDate)\n\(items)\n")
                        self.setSubscriptionState(active: false)
                    case .notPurchased:
                        print("The user has never purchased \(productIds)")
                        self.setSubscriptionState(active: false)
                    }
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            }
        }

        initResult(subscriptionActive)
    }


    func restoreProducts() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                self.restoreResult(false)
            } else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                self.setSubscriptionState(active: true)
                self.restoreResult(true)
            } else {
                print("Nothing to Restore")
                self.restoreResult(false)
            }
        }
    }

    func purchaseProduct(id: String) {
        SwiftyStoreKit.purchaseProduct(id, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                let defaults = UserDefaults.standard
                var data = Calendar.current.date(byAdding: .day, value: 1, to: Date())
                data = Calendar.current.date(byAdding: .minute, value: 5, to: data!)
                defaults.set(data, forKey: "nextCheck")

                print("Purchase Success: \(purchase.productId)")
                self.setSubscriptionState(active: true)
                self.purchaseResult(true)
            case .error(let error):
                self.purchaseResult(false)
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }


    }

    func setSubscriptionState(active: Bool) {
        if subscriptionActive {
            return
        }
        subscriptionActive = active
        defaults.set(active, forKey: "isSubscriptionActive")
    }
}
