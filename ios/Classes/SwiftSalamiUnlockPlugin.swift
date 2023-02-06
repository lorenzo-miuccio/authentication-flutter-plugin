import Flutter
import UIKit
import LocalAuthentication

enum AuthResult: String {
    case success = "Success"
    case failure = "Failure"
    case unknown = "Unknown"
    case updateNeeded = "UpdateNeeded"
    case TBD = "TBD"
    case Unsupported = "Unsupported"
}

public class SwiftSalamiUnlockPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "salami_unlock", binaryMessenger: registrar.messenger())
        let instance = SwiftSalamiUnlockPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if(call.method == "requireDeviceCredentialsSetup") {
            result(false)
        } else if(call.method == "requireUnlock") {
            let args = call.arguments as? [String: Any]
            let message = args?["message"] as? String ?? "Unlock screen"
            
            var authError: NSError?
            var localAuthContext = LAContext()
            
            if localAuthContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
                localAuthContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: message) { success, evaluateError in
                    if success {
                        result(AuthResult.success.rawValue)
                    } else {
                        result(AuthResult.failure.rawValue)
                    }
                }
            } else {
                print(authError?.localizedDescription ?? "Can't evaluate policy")
                
                switch authError?.code {
                case LAError.biometryLockout.rawValue:
                    result(AuthResult.failure.rawValue)
                case LAError.biometryNotEnrolled.rawValue, LAError.passcodeNotSet.rawValue:
                    result(AuthResult.TBD.rawValue)
                case LAError.biometryNotAvailable.rawValue:
                    result(AuthResult.Unsupported.rawValue)
                default:
                    result(AuthResult.unknown.rawValue)
                }
            }
        }
    }
}
