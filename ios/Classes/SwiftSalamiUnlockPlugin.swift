import Flutter
import UIKit
import LocalAuthentication

enum AuthResult: String {
    case success = "Success"
    case failure = "Failure"
}

public class SwiftSalamiUnlockPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "salami_unlock", binaryMessenger: registrar.messenger())
        let instance = SwiftSalamiUnlockPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if(call.method == "getPlatformVersion") {
            result("iOS " + UIDevice.current.systemVersion)
        } else if(call.method == "requireUnlock") {
            let args = call.arguments as? [String: Any]
            let message = args?["message"] as? String ?? "Unlock screen"
            
            var localAuthContext = LAContext()
            var authError: NSError?
            if localAuthContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
                localAuthContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: message) { success, evaluateError in
                    if success {
                        result(AuthResult.success.rawValue)
                    } else {
                        result(AuthResult.failure.rawValue)
                    }
                }
            } else {
                result(AuthResult.failure.rawValue)
            }
        }
    }
}
