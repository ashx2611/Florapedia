//
//  DetailViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 5/1/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import Firebase
let imageCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    
    func loadImageUsingCacheWithUrlString(_ urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
    
}
class DetailViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var NoteName: UITextField!
    @IBOutlet weak var flowerPostimage: UIImageView!
    @IBOutlet weak var flowerPosttext: UITextView!
    @IBOutlet weak var flowerPostsavebuton: UIButton!
    var notes : Note?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(self.notes != nil)
        {
            NoteName.text = self.notes?.name
          
            if let ImageUrl = self.notes?.ImageUrl {
                flowerPostimage?.loadImageUsingCacheWithUrlString(ImageUrl)
            }
            flowerPosttext.text = self.notes?.text
            flowerPostsavebuton.isHidden = true
        }
        flowerPostimage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        flowerPostimage.isUserInteractionEnabled = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        print("going to handler")
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            flowerPostimage.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }

    @IBAction func flowerPostSaveTapped(_ sender: UIButton) {
        
        let newnote = Note(text: flowerPosttext.text!, uid: (Auth.auth().currentUser?.uid)!, name: NoteName.text!,ImageUrl: "")
       
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("\(imageName).png")
        if let uploadData = UIImagePNGRepresentation(self.flowerPostimage.image!)
        {
            storageRef.putData(uploadData,metadata : nil,completion : {(metadata,error)in
                if error != nil {
                    print(error as Any)
                    return
                }
                if let ImageUrl = metadata?.downloadURL()?.absoluteString
                {
                    let values = ["name" : newnote.name , "text" : newnote.text,"ImageUrl" : ImageUrl,"uid" :newnote.uid]
                    self.registerUserIntoDatabaseWithUID(uid: newnote.uid!, values: values as [String : AnyObject])
                }
                })
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid : String,values :[String : AnyObject])
    {
        let ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/")
        let usersReference = ref.child("notes").child(uid).childByAutoId()
        
        usersReference.updateChildValues(values,withCompletionBlock : {(err,red) in
            if err != nil {
                print(err as Any)
                return
            }
            self.dismiss(animated: true, completion: nil)
            
        })
        
    }

}

 
 
 
 
 
 


 

 
 
 
 
 
 
 
 

