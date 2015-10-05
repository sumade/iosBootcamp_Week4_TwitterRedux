//
//  HomelineTableCellTableViewCell.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class HomelineTableViewCell: UITableViewCell {
    
    
    // MARK: ui outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var tweetDate: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    
    var tweet : Tweet! {
        didSet {
            if let user = tweet.user {
                profileImage.setImageWithURL(NSURL(string: user.profileImageURL!)!)
                profileImage.layer.cornerRadius = 10
                profileImage.clipsToBounds = true
                profileImage.contentMode = .ScaleAspectFit
                screenName.text = "@" + user.screenName!
                userName.text = user.name
            }
            tweetDate.text = tweet.sinceDateString
            tweetText.text = tweet.text
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutMargins = UIEdgeInsetsZero
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}