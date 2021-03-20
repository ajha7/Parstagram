//
//  EditProfileViewController.swift
//  Parstagram
//
//  Created by Anshul Jha on 3/17/21.
//

import UIKit
import Parse
import AlamofireImage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var biographyTextField: UITextField!
    
    var user = PFUser.current()!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backButtonTitle = "Cancel"
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: PFUser.current()!.objectId!)
        do {
            user = try userQuery!.findObjects().first as! PFUser
            if user["profile_photo"] != nil {
                let imageFile = user["profile_photo"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                
                imageView.af.setImage(withURL: url)
            } else {
                imageView.image = UIImage(named: "profile_tab")
            }
        } catch let error {
            print("error retrieving error: \(error)")
        }
    }
    
    @IBAction func onFinishChanges(_ sender: Any) {
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(data: imageData!)
        user["profile_photo"] = file
        
        let usernameText = usernameTextField.text
        if usernameText != "" {
            user["username"] = usernameText
        }
        
        let passwordText = passwordTextField.text
        if passwordText != "" {
            user["password"] = passwordText
        }
        
        let biographyText = biographyTextField.text
        if biographyText != "" {
            user["biography"] = biographyText
        }
        
        saveUser()
    }
    
    @IBAction func onProfileClick(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        /*if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {*/
            picker.sourceType = .photoLibrary
        //}
        
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 90, height: 90)
        let scaledImage = image.af.imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        dismiss(animated: true, completion: nil)
    }

    func saveUser() {
        user.saveInBackground { (success, error) in
            if success {
                self.navigationController?.popViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
                print("saved!")
            } else {
                print("error!")
            }
        }
    }

}
