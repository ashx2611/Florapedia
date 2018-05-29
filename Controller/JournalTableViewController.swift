//
//  JournalTableViewController.swift
//  Florapedia
//
//  Created by Ashwini Shekhar Phadke on 5/1/18.
//  Copyright © 2018 Ashwini Shekhar Phadke. All rights reserved.
//

import UIKit
import Firebase
class JournalTableViewController: UITableViewController,UISearchBarDelegate {
    var notelist = [Note]()
    var currentnotelist = [Note]()
     var searchActive : Bool = false
     let profileImageView = UIImageView()
    @IBOutlet weak var logoutbtn: UIBarButtonItem!
    func setupNavBarWithUser(_ user: User) {
        let titleView = UIView()
        let containerView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.redColor()
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
    }
    
    @IBAction func logouttapped(_ sender: UIBarButtonItem) {
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
    //  var key : String?
    @IBOutlet weak var searchbar: UISearchBar!
    @IBOutlet weak var addnotebuuton: UIBarButtonItem!
    override func viewWillAppear(_ animated: Bool) {
        loaddata()
        let uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: {(DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String:AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user)
                print(user.name as Any)
                self.tableView.reloadData()
            }
        }, withCancel: nil)
        
        
        
        
        
        
        
    }
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
   tableView.dataSource = self
   tableView.delegate = self
        searchbar.delegate = self
        currentnotelist = notelist
        loaddata()
        tableView.reloadData()
        tableView.allowsMultipleSelectionDuringEditing = true
        self.hideKeyboard()
    }
    
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        currentnotelist = notelist
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard !searchText.isEmpty else
        {
            currentnotelist = notelist
            tableView.reloadData()
            return
        }
        
        currentnotelist = notelist.filter({(text) -> Bool in
            (text.name?.lowercased().contains(searchText.lowercased()))!
        })
        if(currentnotelist.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
   
    @IBAction func addbuttontapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "addnote", sender: self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(searchActive)
        {
            return currentnotelist.count
        }
        return self.notelist.count
    }
    
    
    func loaddata()
    {
        
        let uid = Auth.auth().currentUser?.uid
        // self.reviews.removeAll()
        let ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/")
        // let usersReference = ref.child("reviews").child(String(describing: "\((movie!.id)!)")).observeSingleEvent(of: .value, with: {(DataSnapshot) in
        let usersReference = ref.child("notes").child(uid!).observe(.value, with: {(DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String:AnyObject] {
              //  print("Printing datasnapshot")
              //  print(DataSnapshot)
                
                
                var tempnotes = [Note]()
                
                
                for child in DataSnapshot.children
                {
                    let childSnapshot = child as! DataSnapshot
                    let childShapshotData = childSnapshot.value
                    
                    let notes  = Note(snapshot: childSnapshot)
                    tempnotes.insert(notes, at: 0)
                    //print("Inside review cell")
                   // print((review.text)!)
                    
                }
                self.notelist = tempnotes
                self.currentnotelist = self.notelist
                self.tableView.reloadData()
            }
        }, withCancel: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Categorycell", for: indexPath)
       if(searchActive)
        {
            cell.textLabel?.text = currentnotelist[indexPath.row].name
            
           let ImageUrl = currentnotelist[indexPath.row].ImageUrl!
            let urlpath = ImageUrl
            /////code for favorite
            
            
            if let imageURL = URL(string : urlpath){
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf : imageURL)
                    if let data = data{
                        let image = UIImage(data : data)
                        DispatchQueue.main.async {
                            cell.imageView?.image = image
                        }
                    }
                }
            }
            
            cell.imageView?.image = #imageLiteral(resourceName: "anonuser")
            //cell.imageView?.loadImageUsingCacheWithUrlString(ImageUrl)
        }
        else
        {
            cell.textLabel?.text = notelist[indexPath.row].name
            
            cell.imageView?.image = UIImage(named : "anonuser")
            let ImageUrl = notelist[indexPath.row].ImageUrl!
         //   let ImageUrl = currentnotelist[indexPath.row].ImageUrl!
            let urlpath = ImageUrl
            /////code for favorite
            
            
            if let imageURL = URL(string : urlpath){
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf : imageURL)
                    if let data = data{
                        let image = UIImage(data : data)
                        DispatchQueue.main.async {
                            cell.imageView?.image = image
                        }
                    }
                }
            }
            
            cell.imageView?.image = #imageLiteral(resourceName: "anonuser")
            //cell.imageView?.loadImageUsingCacheWithUrlString(ImageUrl)
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailVC.notes = notelist[indexPath.row]
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   
            let uid = Auth.auth().currentUser?.uid
         var  queryref : DatabaseQuery
            var  ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/").child("notes").child(uid!)
        if(searchActive)
        {
            queryref  = ref.queryOrdered(byChild: "name").queryEqual(toValue: currentnotelist[indexPath.row].name!)
            print("current node")
            print(currentnotelist.count)
        }
        else
        {
            queryref  = ref.queryOrdered(byChild: "name").queryEqual(toValue: notelist[indexPath.row].name!)
            print("node count")
            print(notelist.count)
            
        }
        
        queryref.observe(.value, with: {(DataSnapshot) in
            var key : String?
                for child in DataSnapshot.children
                {
                    let userSnap = child  as! DataSnapshot
                    key = userSnap.key
                   
                }
           
           
        print("printing key")
        print(key as Any)
       //
               // let newkey = key
           if(key != nil)
            {
                 ref = Database.database().reference(fromURL: "https://florapedia-277ea.firebaseio.com/").child("notes").child(uid!).child(key!)
            }
            
                ref.removeValue(completionBlock: { (error,refer) in
                    if error != nil {
                        print(error as Any)
                        
                    }
                    else {
                        print(refer)
                        print("removed child successfully")
                      
                        self.loaddata()
                        self.tableView.reloadData()
                        
                    }
                }) })
        
        
    }
    
}
