//
//  LocationAnnotaionModel.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 5/3/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LocationAnnotation  : NSObject {
    var uid: String?
    var latitude : Double?
    var longitude : Double?
    var name : String?
    var ref : DatabaseReference?
    
    
    init(dictionary: [String: AnyObject]) {
        self.uid = dictionary["uid"] as? String
        self.latitude = dictionary["latitude"] as? Double
        self.longitude = dictionary["longitude"] as? Double
        self.name = dictionary["name"] as? String
        
        self.ref = (dictionary["ref"] as? DatabaseReference)!
       
    }
    
    init(name  : String, uid : String,latitude : Double,longitude  : Double){
        self.name = name as? String
        
        self.uid = uid as? String
        self.latitude = latitude as? Double
        self.longitude = longitude as? Double
        self.ref = ref as? DatabaseReference
        //ref = Database.database().reference(fromURL: "https://assignment4-b137e.firebaseio.com/").child("reviews").child(String(describing: "\((movie!.id)!)"))
    }
    
    init(snapshot : DataSnapshot)
    {
        
        ref = snapshot.ref
        if let value = snapshot.value as? [String : Any] {
            name = value["name"] as! String
            longitude = value["longitude"] as! Double
            uid = value["uid"] as! String
            latitude = value["latitude"] as! Double
            
        }
    }
    
    func toDictionary() -> [String : Any]
    {
        return [
            "uid" : uid,
            "latitude" :latitude,
            "longitude" :  longitude,
            "name" : name
        ]
    }
    
    
}



