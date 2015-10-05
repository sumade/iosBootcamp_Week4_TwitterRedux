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
    
    var tweet : Tweet?
    
    private var characterCount : Int = 140 {
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
    
    var replyUser : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        profileImageView.setImageWithURL(NSURL(string:(User.currentUser?.profileImageURL!)!)!)
        characterCountLabel.text = "\(characterCount)"
        tweetTextView.delegate = self
        
        // keyboard handling
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if let user = replyUser {
            tweetTextView.text = "@" + user.screenName!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        tweetTextView.textColor = UIColor.blackColor()
        if replyUser == nil {
            tweetTextView.text = ""
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        characterCount = 140-(tweetTextView.text?.characters.count)!
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    /*
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        characterCount = 140-(tweetTextView.text?.characters.count)!
        return true
    }
    */

    @IBAction func sendTweet(sender: AnyObject) {
        if let text = tweetTextView.text where !text.isEmpty {
            // tweet to compose
            let params : Dictionary<String, String>= ["status":text]
            Twitter.sendTweet(text, params: params) {
                (tweet: Tweet?, error: NSError?) -> Void in
                if error == nil {
//                    print("Tweet sent successfully! has idStr=\(tweet?.idStr)")
                    self.tweet = tweet
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tweetTextView.endEditing(true)
                        self.performSegueWithIdentifier(Constants.Segues.sentTweetSegueName, sender: self)
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
