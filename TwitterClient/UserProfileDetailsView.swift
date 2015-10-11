//
//  UserProfileHeaderView.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/10/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit


class UserProfileDetailsView: UIView {

    // MARK: model
    weak var user : User! {
        didSet {
            profileImageView.setImageWithURL(NSURL(string: user.profileImageURL!)!)
            profileImageView.layer.cornerRadius = 10
            profileImageView.clipsToBounds = true
            profileImageView.contentMode = .ScaleAspectFit
            userNameLabel.text = user.name
            screenNameLabel.text = "@" + user.screenName!
            
            descriptionTextLabel.text = user.descriptionText
            
            if let location = user.location {
                locationLabel.text = location
                locationImageView.hidden = false
                locationLabel.hidden = false
            }else{
                // set image to hidden
                locationImageView.hidden = true
                locationLabel.hidden = true
            }
            
            if let profileURL = user.profileURL {
                profileUrlTextView.text = profileURL
                urlImageView.hidden = false
                profileUrlTextView.hidden = false
            }else{
                urlImageView.hidden = true
                profileUrlTextView.hidden = true
            }
            numTweetsLabel.text = Helpers.formatNumberAsCondensed(user.numberOfTweets)
            numFollowersLabel.text = Helpers.formatNumberAsCondensed(user.followersCount)
            numFollowingLabel.text = Helpers.formatNumberAsCondensed(user.followingCount)
            
            if user.verified {
                verifiedImageView.hidden = false
            }else{
                verifiedImageView.hidden = true
            }

            if user.isFollowedByCurrentUser {
                followButton.setBackgroundImage(UIImage(named: "following_user"), forState: .Normal)
            }else{
                followButton.setBackgroundImage(UIImage(named: "follow_user"), forState: .Normal)
            }
        }
    }
    
    // MARK : ui outlets
    @IBOutlet private var contentView: UIView!
    @IBOutlet private(set) weak var userNameLabel: UILabel!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var screenNameLabel: UILabel!
    @IBOutlet private weak var descriptionTextLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var profileUrlTextView: UITextView!
    @IBOutlet private weak var numTweetsLabel: UILabel!
    @IBOutlet private weak var numFollowingLabel: UILabel!
    @IBOutlet private weak var numFollowersLabel: UILabel!
    @IBOutlet weak var verifiedImageView: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var urlImageView: UIImageView!
    @IBOutlet weak var locationImageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubviews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    func initSubviews() {
        // standard initialization logic
        let nib = UINib(nibName: "UserProfileDetailsView", bundle: nil)
        nib.instantiateWithOwner(self, options: nil)
        contentView.frame = bounds
        addSubview(contentView)

        // necessary for the url text view...
        profileUrlTextView.textContainerInset = UIEdgeInsetsZero;
        profileUrlTextView.textContainer.lineFragmentPadding = 0;
        
        descriptionTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(descriptionTextLabel.frame)
            
    }
    
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        descriptionTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.bounds)
//        super.layoutSubviews()
//    }
    
    // MARK: Actions
    @IBAction func followButtonTapped(sender: UIButton) {
        if user.isFollowedByCurrentUser {
            // unfollow, and update button
            print("unfollow!")
        }else{
            // follow , and update button
            print("follow!")
        }
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
