//
//  ComposeTweetViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/4/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate {

    // MARK: ui outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var tweetTextView: UITextView!
    
    private var tweet : Tweet?
    weak var replyTweet : Tweet?
    weak var atUser : User?
    
    private static let maxCharacters = 140
    
    private var characterCount : Int = maxCharacters {
        didSet {
            characterCountLabel.text = "\(characterCount)"
            if characterCount < 0 {
                characterCountLabel.textColor = UIColor.redColor()
                tweetButton.enabled = false
                tweetButton.backgroundColor = Constants.Colors.LightGrey
            }else if characterCount < 10 {
                characterCountLabel.textColor = UIColor.redColor()
                tweetButton.enabled = true
                tweetButton.backgroundColor = Constants.Colors.Blue
            }else{
                characterCountLabel.textColor = Constants.Colors.MedGrey
                tweetButton.backgroundColor = Constants.Colors.Blue
                tweetButton.enabled = true
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImageView.setImageWithURL(NSURL(string:(User.currentUser?.profileImageURL!)!)!)
        characterCountLabel.text = "\(characterCount)"
        tweetTextView.delegate = self
        
        // configure user name if retweet
        if let user = replyTweet?.user {
            tweetTextView.text = "@" + user.screenName!
        }
        
        // or configure use name if at user
        if let user = atUser {
            tweetTextView.text = "@" + user.screenName!
        }

        // keyboard handling
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        tweetTextView.textColor = UIColor.blackColor()
        if let _ = replyTweet?.user, let _ = atUser {
            // do nothing for now
        }else{
            // clear the text field
            tweetTextView.text = ""
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        characterCount = ComposeTweetViewController.maxCharacters-(tweetTextView.text?.characters.count)!
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    

    @IBAction func sendTweet(sender: AnyObject) {
        if let text = tweetTextView.text where !text.isEmpty {
            // tweet to compose
            var params : Dictionary<String, String>= [Constants.TwitterParams.tweetText:text]
            
            // if in reply to....
            if let reply = replyTweet {
                params[Constants.TwitterParams.replyToStatus] = reply.idStr
            }
            
            Twitter.sendTweet(text, params: params) {
                (tweet: Tweet?, error: NSError?) -> Void in
                if error == nil, let tweet=tweet {
                    let userInfo = ["tweet":tweet]
                    NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.tweetCreated, object: nil, userInfo: userInfo)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tweetTextView.endEditing(true)
                        self.dismissViewControllerAnimated(true, completion:nil)
                    })
                }else{
                    print("ruh roh. couldn't send tweet")
                }
            }
        }
        
    }

    @IBAction func cancelTapped(sender: AnyObject) {
        self.tweetTextView.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    func keyboardWillShow(notification: NSNotification!) {
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let offsetSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationDuration = durationValue.doubleValue
        
        if keyboardSize.height == offsetSize.height {
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                self.bottomConstraint.constant = keyboardSize.height + 8
            })
        }else{
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                self.bottomConstraint.constant = offsetSize.height + 8
            })
        }
    }
    
    func keyboardWillHide(notification: NSNotification!) {
        let userInfo: [NSObject : AnyObject] = notification.userInfo!
        let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let animationDuration = durationValue.doubleValue
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.bottomConstraint.constant = 8
        })
    }
}
