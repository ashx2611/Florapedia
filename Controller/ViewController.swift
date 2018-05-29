//
//  ViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 4/26/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import Social
import Firebase
import SVProgressHUD




extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}


class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    

     @IBOutlet weak var shareButton: UIButton!
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        shareButton.isHidden = true
        
        //imagePicker.sourceType = .camera
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let alertController = UIAlertController.init(title: nil, message: "Device has no camera.", preferredStyle: .alert)
            
            let okAction = UIAlertAction.init(title: "Alright", style: .default, handler: {(alert: UIAlertAction!) in
            })
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        else{
            imagePicker.sourceType = .camera
        }        //        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
   
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var uploadimage =  UIImage()
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker,animated: true,completion: nil)
    }
    
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        do{
            try  Auth.auth().signOut()
            
            let welcomeviewcontroller  = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
            let navcontroller = UINavigationController(rootViewController : welcomeviewcontroller )
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = navcontroller
         
        }
        catch{
            print ("Error in signing out")
        }
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
          guard   let convertedCIImage = CIImage(image : userPickedImage) else {
                fatalError("Cannot convert to CIImage")
            }
            detect(image : convertedCIImage)
            imageView.image = userPickedImage
            uploadimage = userPickedImage
        }
       
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image : CIImage)
    {
        SVProgressHUD.show()
        guard let model = try?VNCoreMLModel(for : FlowerClassifier().model) else {
            fatalError("cannot import model")
        }
            let request  = VNCoreMLRequest(model : model){(request,error) in
                guard   let classification = request.results?.first as? VNClassificationObservation else{
                    fatalError("Could not classify image")
                    
                }
                
                self.navigationItem.title = classification.identifier.capitalized
                self.requestInfo(flowerName: classification.identifier)
                self.shareButton.isHidden = false
                
            }
        
       let handler  = VNImageRequestHandler(ciImage : image)
        do {
            try handler.perform([request])
            
        }
            
        
        catch{
            print(error)
        }
        SVProgressHUD.dismiss()
        
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func shareTapped(_ sender: UIButton) {
        
      /*  if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.setInitialText("Hello friends!I just discovered a new flower called \(String(describing: navigationItem.title))!Ain't that cool?")
            fbShare.add(uploadimage)
            
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }*/
        
        let activityController = UIActivityViewController(activityItems: [descLabel.text as Any,imageView.image as Any], applicationActivities: nil )
        present(activityController,animated: true,completion: nil)
        
        
        
    }
    func requestInfo(flowerName : String)
    {
        
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : " ",
            "redirects" : "1",
        
        
            ]

        Alamofire.request(wikipediaURl,method : .get, parameters : parameters).responseJSON
            {(response) in
                if response.result.isSuccess{
                    print("Got the wikipedia info")
                    print(response)
                    
                    let flowerJSON : JSON = JSON(response.result.value!)
                    let pageid = flowerJSON["query"]["pageids"][0].stringValue
                    let flowerdescp = flowerJSON["query"]["pages"][pageid]["extract"].stringValue
                    
                    self.descLabel.text = flowerdescp
                }
        }

    }

}


