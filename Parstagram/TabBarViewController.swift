//
//  TabBarViewController.swift
//  Parstagram
//
//  Created by Anshul Jha on 3/18/21.
//

import UIKit
import Parse

class TabBarViewController: UITabBarController {

    
    @IBOutlet weak var tabBarNavigation: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userQuery = PFUser.query()
        userQuery!.whereKey("objectId", equalTo: PFUser.current()!.objectId)
        do {
            var user =  try userQuery!.findObjects().first as! PFUser
            
            if user["profile_photo"] != nil {
                let imageFile = user["profile_photo"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                var img = UIImage(data: try Data(contentsOf: url))
                img = scaleImage(img: img!)
                let tabBarItem1 = (self.tabBar.items?[1])! as UITabBarItem
                tabBarItem1.image = (img)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            }
        } catch let error {
            print("Error finding user, \(error)")
        }
    }
    
    func scaleImage(img: UIImage) -> UIImage{
        let size = CGSize(width: 30, height: 30)
        let scaledImage = img.af_imageAspectScaled(toFit: size)
        return scaledImage
    }

}
