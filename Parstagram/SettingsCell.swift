//
//  SettingsCell.swift
//  Parstagram
//
//  Created by Anshul Jha on 3/16/21.
//

import UIKit

class SettingsCell: UITableViewCell {

    lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        return view
    }()
    
    lazy var settingImage: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var settingsLabel: UILabel = {
        let settingsLabel = UILabel(frame: CGRect(x: 60, y: 10, width: self.frame.width - 80, height: 30))
        return settingsLabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(backView)
        backView.addSubview(settingImage)
        backView.addSubview(settingsLabel)
        // Configure the view for the selected state
    }

}
