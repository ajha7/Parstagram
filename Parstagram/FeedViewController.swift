//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Anshul Jha on 3/12/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
 
    var posts = [PFObject]()
    let commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        tableView.estimatedRowHeight = 53
        tableView.rowHeight = UITableView.automaticDimension
        
        addInstagramLogo()
        /*
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: PFUser.current()!.objectId)
        do {
            var user =  try userQuery!.findObjects().first as! PFUser
            
            if user["profile_photo"] != nil {
                let imageFile = user["profile_photo"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                
            }
        } catch let error {
            print("Error finding user, \(error)")
        }*/
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func addInstagramLogo() {
        let logo = UIImage(named: "instagram_logo")
        let imageView = UIImageView(image: logo)
        imageView.frame = CGRect(x: -40, y: 0, width: 140, height: 80)
       // imageView.contentMode = .scaleAspectFit
        let imageItem = UIBarButtonItem.init(customView: imageView)
        navigationItem.leftBarButtonItem = imageItem
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let numComments = (post["comments"] as? [PFObject]) ?? []
        return numComments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let post = posts[indexPath.section]
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = (post["caption"] as! String)
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af.setImage(withURL: url)
            cell.posterUsername.text = user.username
            if user["profile_photo"] != nil {
                let imageFile = user["profile_photo"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                do {
                    var img = UIImage(data: try Data(contentsOf: url))
                    img = scaleImage(img: img!)
                    cell.posterProfileImage.image = img
                    cell.posterCommentImage.image = img
                }
                catch let error {print("no img")}
            }
            
            return cell
        } else if indexPath.row <= comments.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]

            cell.commentLabel.text = comment["text"] as? String
        
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            if user["profile_photo"] != nil {
                let imageFile = user["profile_photo"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                do {
                    var img = UIImage(data: try Data(contentsOf: url))
                    img = scaleImage(img: img!)
                    
                    cell.profileImage.image = img
                }
                catch let error {print("no img")}
            }
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create the comment
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground { (success, error) in
            if success {
                print ("Comment saved")
            } else {
                print ("Error saving comment: " + error!.localizedDescription)
            }
        }
        
        tableView.reloadData()
        
        //Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            self.becomeFirstResponder() //why?
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scaleImage(img: UIImage) -> UIImage {
            let size = CGSize(width: 30, height: 30)
            let scaledImage = img.af_imageAspectScaled(toFit: size)
            return scaledImage
    }
}
