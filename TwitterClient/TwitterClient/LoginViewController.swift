//
//  ViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, TwitterLoginHandler {

    // MAIN: ui outlets
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        loginButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginButton.layer.borderWidth = 1.0

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }


    @IBAction func loginTapped(sender: AnyObject) {
        Twitter.login(self)
    }
    
    // MARK: Twitter login delegates
    func loginCompletion() -> Void {
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.userDidLoginNotification, object: nil)
//        self.performSegueWithIdentifier(Constants.Segues.loginToHomeTimeline,  sender: self)
        
    }
    
    func loginFailure(error: NSError?) -> Void {
        print("login error: \(error)")
    }

}

