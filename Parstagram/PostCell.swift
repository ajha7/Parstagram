//
//  PostCell.swift
//  Parstagram
//
//  Created by Anshul Jha on 3/12/21.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var posterUsername: UILabel!
    @IBOutlet weak var posterCommentImage: UIImageView!
    
    @IBOutlet weak var posterProfileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
