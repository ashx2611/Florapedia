//
//  MapViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 5/3/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
class MapViewController: UIViewController,CLLocationManagerDelegate,UIGestureRecognizerDelegate ,MKMapViewDelegate{

   
   var text = ""
    var text1 = ""
    var locati = [LocationAnnotation]()
    var locCord = CLLocationCoordinate2D()
    
    var  annotation = MKPointAnnotation()
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.isUserInteractionEnabled = true
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(self.tapgesture) )
        tapgesture.delegate = self
        
        mapView.addGestureRecognizer(tapgesture)
        
        loadmapdata()
      
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
 
    @objc  func tapgesture(tapgesture : UITapGestureRecognizer){
    print("Inside function tap")
         let location1 = tapgesture.location(in: self.mapView)
   let alert = UIAlertController(title: "Found something interesting??", message: "Note it down!!", preferredStyle: UIAlertControllerStyle.alert)
    let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction)  in
        let textField = alert.textFields![0] as UITextField
        self.text =   textField.text!
        
        let location = location1
        let locCord = self.mapView.convert(location,toCoordinateFrom :self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCord
        annotation.title = self.text
        self.mapView.addAnnotation(annotation)
        let newcordinate = LocationAnnotation(name: self.text, uid: (Auth.auth().currentUser?.uid)!, latitude: locCord.latitude, longitude: locCord.longitude)
        let values = ["name" :newcordinate.name as Any,"uid":newcordinate.uid as Any,"latitude":newcordinate.latitude as Any,"longitude":newcordinate.longitude as Any] as [String : Any]
        self.registerreviewIntoDatabaseWithID(uid: newcordinate.uid!, values: values as [String : AnyObject])
        
        }
    
    alert.addTextField { (textField) in
        textField.placeholder = "Enter description"
    }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            print("Cancel button tapped");
        }
        alert .addAction(cancelAction)
    alert.addAction(action)
       
        self.present(alert, animated: true, completion:nil )
    }
   
    
    func loadmapdata ()
    {
        let uid = Auth.auth().currentUser?.uid
       
        let ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/")
        // let usersReference = ref.child("reviews").child(String(describing: "\((movie!.id)!)")).observeSingleEvent(of: .value, with: {(DataSnapshot) in
        let usersReference = ref.child("places").child(uid!).observeSingleEvent(of : .value, with: {(DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String:AnyObject] {
                  print("Printing datasnapshot")
                 print(DataSnapshot)
                var temploc  = [LocationAnnotation]()
                for child in DataSnapshot.children
                {
                    let childSnapshot = child as! DataSnapshot
                    let childShapshotData = childSnapshot.value
                    
                    let loc   = LocationAnnotation(snapshot: childSnapshot)
                   temploc.insert(loc , at: 0)
                    let CLLCoordType = CLLocationCoordinate2D(latitude: temploc[0].latitude!, longitude: temploc[0].longitude!)
                  //  print(location.latitude!)
                    let annot = MKPointAnnotation()
                    annot.coordinate = CLLCoordType
                    
                    
                    annot.title = temploc[0].name!
                    print("adding annotation")
                    self.mapView.addAnnotation(annot)
                    
                }
                self.locati = temploc
                
                
               
            }
        })
        
    }
    
    
    private func registerreviewIntoDatabaseWithID(uid : String,values :[String : AnyObject])
    {
        let ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/")
        let usersReference = ref.child("places").child(uid).childByAutoId()
      
        usersReference.updateChildValues(values,withCompletionBlock : {(err,red) in
            if err != nil {
                print(err as Any)
                return
            }
       // self.dismiss(animated: true, completion: nil)
            
        })
   
    }
}






