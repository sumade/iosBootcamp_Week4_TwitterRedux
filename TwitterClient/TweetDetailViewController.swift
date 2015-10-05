//
//  TweetDetailViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/4/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    private static let timeFormatter : NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "h:mma dd MMM y"
        return formatter
    }()

    
    // MARK: UI Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var retweetFavoriteCountLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetNameLabel: UILabel!
    @IBOutlet weak var retweetView: UIView!
    @IBOutlet weak var retweetViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Model
    private var myTweet : Tweet! {
        didSet {
            if var user = myTweet.user {
                if let replyTweet = myTweet.retweet {
                    retweetNameLabel.text = user.name! + " Retweeted"
                    user = replyTweet.user!
                    retweetViewHeightConstraint.constant = 16
                    retweetView.hidden = false
                }else{
                    retweetView.hidden = true
                    retweetViewHeightConstraint.constant = 0
                }
            
                profileImageView.setImageWithURL(NSURL(string: user.profileImageURL!)!)
                profileImageView.layer.cornerRadius = 10
                profileImageView.clipsToBounds = true
                profileImageView.contentMode = .ScaleAspectFit
                screenNameLabel.text = "@" + user.screenName!
                usernameLabel.text = user.name
            }
            
            tweetTextView.text = myTweet.text
            timestampLabel.text = TweetDetailViewController.timeFormatter.stringFromDate(myTweet.createdDate!)
            
           // if User.currentUser!.didFavoriteTweet(myTweet.idStr!) {
            if myTweet.favorited {
                favoriteButton.setBackgroundImage(UIImage(named: "favorite_on"), forState: .Normal)
            }
            
            if myTweet.retweeted {
                retweetButton.setBackgroundImage(UIImage(named:"retweet_on"), forState: .Normal)
            }
            
            retweetFavoriteCountLabel.text = "(\(myTweet.retweetCount)) RETWEET \t (\(myTweet.favoriteCount)) FAVORITE"
        }
    }
    
    // holder for segue
    var holderTweet : Tweet!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the tweet  --> hack because using segues to manage the transition between view controllers
        myTweet = holderTweet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == Constants.Segues.replyToTweetSegue {
            let composeVC = segue.destinationViewController as! ComposeTweetViewController
            composeVC.replyTweet = myTweet
        }
    }
    
    // MARK: UI actions    
    @IBAction func favoriteButtonTapped(sender: AnyObject) {
        if( myTweet.favorited ){
            // unfavorite the tweet
            myTweet.unfavorite({ (error) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.favoriteButton.setBackgroundImage(UIImage(named: "favorite_default"), forState: .Normal)
                        self.retweetFavoriteCountLabel.text = "(\(self.myTweet.retweetCount)) RETWEET \t (\(self.myTweet.favoriteCount)) FAVORITE"
                    }
                }
            })
        }else{
            // favorite the tweet
            myTweet.favorite({ (error) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.favoriteButton.setBackgroundImage(UIImage(named: "favorite_on"), forState: .Normal)
                        self.retweetFavoriteCountLabel.text = "(\(self.myTweet.retweetCount)) RETWEET \t (\(self.myTweet.favoriteCount)) FAVORITE"
                    }
                }
            })
        }
    }
    
    @IBAction func retweetButtonTapped(sender: AnyObject) {
        if !myTweet.retweeted {
            myTweet.retweet({ (error) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.retweetButton.setBackgroundImage(UIImage(named: "retweet_on"), forState: .Normal)
                        self.retweetFavoriteCountLabel.text = "(\(self.myTweet.retweetCount)) RETWEET \t (\(self.myTweet.favoriteCount)) FAVORITE"
                    }
                }
            })
        }else{
            
        }
    }

    @IBAction func replyButtonTapped(sender: AnyObject) {
        // do something else?
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func swipeLeftGesture(recognizer:UIPanGestureRecognizer){
        if recognizer.state == .Ended {
            self.dismissViewControllerAnimated(true, completion:nil)
        }
    }
}
