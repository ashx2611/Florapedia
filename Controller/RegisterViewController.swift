//
//  RegisterViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 4/29/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import Firebase


class RegisterViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        profileImage.isUserInteractionEnabled = true
        self.hideKeyboard()
        // Do any additional setup after loading the view.
    }
    @IBOutlet weak var registerscreenButton: UIButton!
    
    @IBAction func registerscreentapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text  else {
            print("Must enter name,email and location  ")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                print(error ?? "")
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("\(imageName).png")
            if let uploadData = UIImagePNGRepresentation(self.profileImage.image!)
            {
                storageRef.putData(uploadData,metadata : nil,completion : {(metadata,error)in
                    if error != nil {
                        print(error as Any)
                        return
                    }
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    {
                        let values = ["name" : name, "email" : email,"profileImageUrl" : profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                    }
                    
                })
            }
            
           // self.performSegue(withIdentifier: "registertotabbar", sender: self)
            let myTabbar = self.storyboard?.instantiateViewController(withIdentifier: "myTabbar") as! UITabBarController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = myTabbar
            
            
        })
    }
    
    
    private func registerUserIntoDatabaseWithUID(uid : String,values :[String : AnyObject])
    {
        let ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/")
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values,withCompletionBlock : {(err,red) in
            if err != nil {
                print(err as Any)
                return
            }
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        print("going to handler")
        picker.delegate = self
        picker.allowsEditing = true
               present(picker, animated: true, completion: nil)
    }
   

}
