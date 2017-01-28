//
//  ProfileViewController.swift
//  RidePath
//
//  Created by Spencer Atkin on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

let kHomeAddressKey = "kHomeAddressKey"

class ProfileViewController: UIViewController, UITextFieldDelegate {

    var ref: FIRDatabaseReference!
    @IBOutlet var userImage: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var usernameOutlet: UITextField!
    @IBOutlet var carModelOutlet: UITextField!
    @IBOutlet var seatsOutlet: UITextField!
    @IBOutlet var homeOutlet: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameOutlet.delegate = self
        carModelOutlet.delegate = self
        seatsOutlet.delegate = self
        homeOutlet.delegate = self
        self.userImage.layer.cornerRadius = self.userImage.frame.size.width / 2;
        self.userImage.clipsToBounds = true;
        

        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let carmodel = value?["carmodel"] as? String ?? ""
            let seats = value?["seats"] as? String ?? ""
            let homeaddress = value?["homeaddress"] as? String ?? ""
            
            self.usernameLabel.text = username
            self.usernameOutlet.text = username
            self.carModelOutlet.text = carmodel
            self.seatsOutlet.text = seats
            self.homeOutlet.text = homeaddress

            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    @IBAction func didTapUpdate(_ sender: Any) {
        if let userID = FIRAuth.auth()?.currentUser?.uid{
        ref.child("users").child(userID).updateChildValues(["username": usernameOutlet.text,"carmodel": carModelOutlet.text,"seats": seatsOutlet.text,"homeaddress": homeOutlet.text])
        usernameLabel.text = usernameOutlet.text
        }
    }
    
    @IBAction func didTapLogout(_ sender: Any) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            self.usernameLabel.text = ""
            self.usernameOutlet.text = ""
            self.carModelOutlet.text = ""
            self.seatsOutlet.text = ""
            self.homeOutlet.text = ""
            performSegue(withIdentifier: "logoutSegue", sender: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
