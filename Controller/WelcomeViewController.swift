//
//  WelcomeViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 4/29/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import Firebase
class WelcomeViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    
    @IBAction func registerTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "gotoRegister", sender: self)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    /*    if (Auth.auth().currentUser != nil)
        {
            print("User is logged in")
            
            
            let myTabbar = self.storyboard?.instantiateViewController(withIdentifier: "myTabbar") as! UITabBarController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = myTabbar
        }
        else
        {
            print("new user")
        }*/
       
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
          performSegue(withIdentifier: "gotoLogin", sender: self)
    }
    
   
}
