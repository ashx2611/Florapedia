//
//  NoteModel.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 5/1/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//



import Foundation
import UIKit
import Firebase

class Note  : NSObject {
    var uid: String?
    var id : String?
    var name : String?
    var text: String?
   var ref : DatabaseReference?
    var ImageUrl: String?
  
    init(dictionary: [String: AnyObject]) {
        self.uid = dictionary["uid"] as? String
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.text = dictionary["text"] as? String
       
        self.ref = (dictionary["ref"] as? DatabaseReference)!
        self.ImageUrl = dictionary["ImageUrl"] as? String
    }
    
    init(text : String, uid : String,name : String,ImageUrl : String){
        self.text = text as? String
      
        self.uid = uid as? String
        self.name = name as? String
        self.ImageUrl = ImageUrl as? String
        self.ref = ref as? DatabaseReference
        //ref = Database.database().reference(fromURL: "https://assignment4-b137e.firebaseio.com/").child("reviews").child(String(describing: "\((movie!.id)!)"))
    }
    
    init(snapshot : DataSnapshot)
    {
        
        ref = snapshot.ref
        if let value = snapshot.value as? [String : Any] {
            text = value["text"] as! String
            name = value["name"] as! String
            uid = value["uid"] as! String
            ImageUrl = value["ImageUrl"] as! String
          
        }
    }
    
    func toDictionary() -> [String : Any]
    {
        return [
            "uid" : uid,
            "name" : name,
            "text" : text,
            "ImageUrl" : ImageUrl
        ]
    }
    
    
}


