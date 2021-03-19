//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Anshul Jha on 3/16/21.
//

import UIKit
import Parse
import Alamofire
import AlamofireImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var biographyLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var settingsArray = ["Logout"]
    var transparentView = UIView()
    var settingsTableView = UITableView()
    let height: CGFloat = 250
    var posts = [PFObject]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.usernameLabel.text = "@" + (PFUser.current()?.username)!
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: PFUser.current()!.objectId)
        
        //userQuery!.whereKeyExists("profile_photo")
        do {
            var user =  try userQuery!.findObjects().first as! PFUser
            
            if user["profile_photo"] != nil {
                let imageFile = user["profile_photo"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                profilePicture.af.setImage(withURL: url)
                
                let img = UIImage(data: try Data(contentsOf: url))
                self.tabBarItem.image = img
            }
            
            if user["biography"] != nil {
                biographyLabel.text = user["biography"] as! String
                biographyLabel.isHidden = false
            }
        } catch let error {
            print("Error finding user, \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
                
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = (view.frame.size.width - layout.minimumInteritemSpacing * 2) / 3
        layout.itemSize = CGSize(width: width, height: width * 1) //1.15
        //collectionView.collectionViewLayout = layout
        let postQuery = PFQuery(className: "Posts")
        postQuery.whereKey("author", equalTo: PFUser.current()!)
        
        postQuery.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
            
                self.postNumberLabel.text = String(self.posts.count) + " Posts"
                self.collectionView.reloadData()
            } else {
                print("Error: \(error?.localizedDescription)")
            }
        }
       
        settingsTableView.isScrollEnabled = true
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostsCollectionViewCell", for: indexPath) as! PostsCollectionViewCell
        
        let post = posts[indexPath.item]
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.postImage.af.setImage(withURL: url)
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.postImage.frame.size.height = cell.frame.height
        cell.postImage.frame.size.width = cell.frame.width
        
        return cell
    }
    
    @IBAction func onSettingsButton(_ sender: UIBarButtonItem) {
        guard let window = UIApplication.shared.windows.first
        else
        {
            return
        }
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        window.addSubview(transparentView)
        
        let screenSize = UIScreen.main.bounds.size
        settingsTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        window.addSubview(settingsTableView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onClickTransparentView))
        transparentView.addGestureRecognizer(tapGesture)
        
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.settingsTableView.frame = CGRect(x: 0, y: screenSize.height - self.height, width: screenSize.width, height: self.height)
        }, completion: nil)
    }
        
    @objc func onClickTransparentView() {
        let screenSize = UIScreen.main.bounds.size
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.transparentView.alpha = 0.5
            self.settingsTableView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: self.height)
        }, completion: nil)
        transparentView.alpha = 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
        cell.settingsLabel.text = settingsArray[indexPath.row]
        cell.settingImage.image = UIImage(named: settingsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCell
        if cell.settingsLabel.text == "Logout" {
            PFUser.logOut()
            
            let main = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let delegate = windowScene.delegate as? SceneDelegate
            else {
                return
            }
            
            delegate.window?.rootViewController = loginViewController
        }
    }
      
    
}
