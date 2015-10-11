//
//  TwitterBurgerTableViewCell.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/11/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class TwitterBurgerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var theImageView: UIImageView!
    @IBOutlet weak var theNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.translatesAutoresizingMaskIntoConstraints = true
        self.backgroundColor = Constants.Colors.MedGrey
        self.theNameLabel.preferredMaxLayoutWidth = CGRectGetWidth(theNameLabel.frame)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
