//
//  LoginViewController.swift
//  RidePath
//
//  Created by Emery Berlik on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase


class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var userNameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        if let email = userNameField.text {
            if let password = passwordField.text {
                if email != "" && password != "" {
                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                                switch errCode {
                                case .errorCodeUserDisabled:
                                    print("user disabled")
                                case .errorCodeWrongPassword:
                                    print("incorrect password")
                                case .errorCodeInvalidEmail:
                                    print("invalid email")
                                default:
                                    print("login error: \(error)")
                                }    
                            }
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func didTapRegister(_ sender: Any) {
        if let email = userNameField.text {
            if let password = passwordField.text {
                if email != "" && password != "" {
                    FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
                                switch errCode {
                                case .errorCodeInvalidEmail:
                                    print("invalid email")
                                case .errorCodeEmailAlreadyInUse:
                                    print("email in use")
                                case .errorCodeWeakPassword:
                                    print("weak password")
                                default:
                                    print("login error: \(error)")
                                }
                            }
                        } else {
                            self.ref = FIRDatabase.database().reference()
                            if let userID = FIRAuth.auth()?.currentUser?.uid{
                            self.ref.child("ids/\(userID)/username").setValue(email)
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }


}

