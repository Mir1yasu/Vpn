import TunnelKit

class PacketTunnelProvider: OpenVPNTunnelProvider {
    
    override init() {
        NSLog("provider init")
        
        super.init()
       
    }
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        super.startTunnel(completionHandler: { (error) in
            print(error ?? "error on gettin error")
        })
    }
}
