//
//  LoginViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 4/29/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       self.hideKeyboard()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginTapped(_ sender: UIButton) {
        SVProgressHUD.show()
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!){(user,error) in
            if (error != nil) {
                 SVProgressHUD.dismiss()
                print(error as Any)
            }
            else {
                print("log in successful")
                SVProgressHUD.dismiss()
                let myTabbar = self.storyboard?.instantiateViewController(withIdentifier: "myTabbar") as! UITabBarController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = myTabbar
                
                
            }
        }
    }
}
