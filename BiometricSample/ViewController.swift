//
//  ViewController.swift
//  BiometricSample
//
//  Created by Michael de Guzman on 9/22/22.
//

import UIKit
import LocalAuthentication
class ViewController: UIViewController {
    
    @IBOutlet weak var authorizeButton: UIButton!
    let context = LAContext()
    var error: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func authorizeAction(_ sender: Any) {
        configureBiometrics()
    }
    
}
 
extension ViewController {
    
    func configureBiometrics(){
         context.localizedFallbackTitle = "Enter Username/Password"
     
        if context.canEvaluatePolicy(
                    LAPolicy.deviceOwnerAuthentication,
                    error: &error) {
                    if #available(iOS 11.0, *) {
                        switch context.biometryType {
                        case .touchID: //For fingerprint
                            authenticate()
                        case .faceID:// for faceid
                            authenticate()
                            break
                        case .none:
                            let alert = UIAlertController(title: "No biometrics available.",
                                                          message: "Please try again.",
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Dismiss",
                                                          style: .cancel,
                                                          handler: nil))
                            self.present(alert, animated: true)
                          
                        default: break
                        }
                    } else {
                        authenticate()
                    }
                } else {
                    print(evaluateAuthenticationPolicyMessageForLA(errorCode: (error?.code)!))
                    let errorMessage = evaluateAuthenticationPolicyMessageForLA(errorCode: (error?.code)!)
                     let alert = UIAlertController(title: "errorMessage",
                                                   message: "\(errorMessage)",
                                                   preferredStyle: .alert)
                     alert.addAction(UIAlertAction(title: "Dismiss",
                                                   style: .cancel,
                                                   handler: nil))
                     self.present(alert, animated: true)
                }
       }
}

extension ViewController {
    
    private func authenticate() {
        let reason = "The app would like to access your biometrics."
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    // User authenticated successfully
                    let vc = UIViewController()
                    vc.title = "Welcome!"
                    vc.view.backgroundColor = .systemBlue
                    self.present(UINavigationController(rootViewController: vc),
                                 animated:  true,
                                 completion: nil)
                } else {
                    // User did not authenticate successfully
                    // Fall back to a asking for username and password.
                    print(error?.localizedDescription ?? "Failed to authenticate")
                    let alert = UIAlertController(title: error?.localizedDescription ?? "Failed to authenticate",
                                                  message: "Please try again.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss",
                                                  style: .cancel,
                                                  handler: nil))
                    self.present(alert, animated: true)
                }
                
            }//dispatchQueue
        }
    }
    
    
}

extension ViewController {
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
           var message = ""
           if #available(iOS 11.0, macOS 10.13, *) {
               switch errorCode {
               case LAError.biometryNotAvailable.rawValue:
                   message = "Authentication could not start because the device does not support biometric authentication."
                   
               case LAError.biometryLockout.rawValue:
                   message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                   
               case LAError.biometryNotEnrolled.rawValue:
                   message = "Authentication could not start because the user has not enrolled in biometric authentication."
                   
               default:
                   message = "Did not find error code on LAError object"
               }
           } else {
               switch errorCode {
               case LAError.touchIDLockout.rawValue:
                   message = "Too many failed attempts."
                   
               case LAError.touchIDNotAvailable.rawValue:
                   message = "TouchID is not available on the device"
                   
               case LAError.touchIDNotEnrolled.rawValue:
                   message = "TouchID is not enrolled on the device"
                   
               default:
                   message = "Did not find error code on LAError object"
               }
           }
           
           return message;
       }
       
       func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
           
           var message = ""
           
           switch errorCode {
               
           case LAError.authenticationFailed.rawValue:
               message = "The user failed to provide valid credentials"
               
           case LAError.appCancel.rawValue:
               message = "Authentication was cancelled by application"
               
           case LAError.invalidContext.rawValue:
               message = "The context is invalid"
               
           case LAError.notInteractive.rawValue:
               message = "Not interactive"
               
           case LAError.passcodeNotSet.rawValue:
               message = "Passcode is not set on the device"
               
           case LAError.systemCancel.rawValue:
               message = "Authentication was cancelled by the system"
               
           case LAError.userCancel.rawValue:
               message = "The user did cancel"
               
           case LAError.userFallback.rawValue:
               message = "The user chose to use the fallback"
               
           default:
               message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
           }
           
           return message
       }
}


    

    

