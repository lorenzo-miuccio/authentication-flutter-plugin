import Flutter
import UIKit
import LocalAuthentication

enum AuthResult: String {
    case success = "Success"
    case failure = "Failure"
    case unknown = "Unknown"
    case updateNeeded = "UpdateNeeded" // currently specified only for android platforms
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
        
        // It's not possible to redirect the user to the local credentials setup page, so the method returns always false to flutter
        if(call.method == "requireDeviceCredentialsSetup") {
            result(false)
            
        
        }
        /// Method called to show the authentication dialog to the user.
        ///
        /// If the user can't be authenticated by biometry or passcode an AuthResult rawvalue will be submitted to Flutter according to the encountered error.
        ///Otherwise the dialog will be displayed.
        ///If the user manages to authenticate the Flutter caller will receive an AuthResult.success, otherwise an AuthResult.failure
        else if(call.method == "requireUnlock") {
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
                switch authError?.code {
                case LAError.biometryLockout.rawValue, LAError.appCancel.rawValue, LAError.systemCancel.rawValue, LAError.userCancel.rawValue:
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
