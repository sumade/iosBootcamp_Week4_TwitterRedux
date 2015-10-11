//
//  HomeTimelineViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit
import SwiftyJSON

class TimelineViewController: UIViewController,  TimelineControllerReloadDelegate, ShowProfileDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: data
    var timelineController = TimelineController()
    
    // MARK: refresh hacks
    var refreshControl : UIRefreshControl!
    
    deinit {
        if !isHandlingMentions {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.tweetCreated, object: nil)
        }
    }
    

    var isHandlingMentions = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineController.reloadDelegate = self
        timelineController.profileViewDelegate = self
        
        // table setup
        homeTableView.delegate = timelineController
        homeTableView.dataSource = timelineController
        homeTableView.estimatedRowHeight = 100
        homeTableView.rowHeight = UITableViewAutomaticDimension
        homeTableView.layoutMargins = UIEdgeInsetsZero
        homeTableView.separatorInset = UIEdgeInsetsZero
        
        // header view setup
        headerView.layer.borderColor = Constants.Colors.Blue.CGColor
        headerView.layer.borderWidth = 1.0
        
        // hack
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "fetchHomeTimeline", forControlEvents: UIControlEvents.ValueChanged)
        
        let dummyTableVC = UITableViewController()
        dummyTableVC.tableView = homeTableView
        dummyTableVC.refreshControl = refreshControl
        
        
        // notification of new tweets - for home timeline only
        if !isHandlingMentions {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "createdNewTweet:", name: Constants.Notifications.tweetCreated, object: nil)
        }
        
        // fetch data
        fetchData()
    }
    
    func fetchData() {
        if !isHandlingMentions {
            fetchTheHomeTimeline()
        }else{
            fetchTheMentions()
        }
    }
    
    func fetchTheHomeTimeline() {
        // get home timeline
        Twitter.homeTimeline(nil) { (tweets, error) -> Void in
            if error == nil {
                self.timelineController.tweets = tweets!
                self.refreshControl.endRefreshing()
                Helpers.printRateStatus()
            }else{
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchTheMentions() {
        // get mentions
        Twitter.mentions(nil) { (tweets, error) -> Void in
            if error == nil {
                self.timelineController.tweets = tweets!
                self.refreshControl.endRefreshing()
                Helpers.printRateStatus()
            }else{
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    // MARK: Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // go to tweet detail
        if let id = segue.identifier where id == Constants.Segues.goToTweetDetail {
            if let cell = sender as? TimelineTableViewCell {
                if let indexPath = homeTableView.indexPathForCell(cell) {
                    let detailVC = segue.destinationViewController as! TweetDetailViewController
                    detailVC.holderTweet = timelineController.tweets[indexPath.row]
                }
            }
        }
        
        // go to profile view
        if let id = segue.identifier where id == Constants.Segues.goToProfileView {
            let profileVC = segue.destinationViewController as! UserProfileViewController
            profileVC.passedUser = sender as? User
        }
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    @IBAction func composeTweetTapped(sender: AnyObject) {
        performSegueWithIdentifier(Constants.Segues.timelineToComposeTweet, sender: self)
    }

    // MARK: Delegates
    // show profile view (from HomelineTableViewCell)
    func showProfileVC(user: User) {
        performSegueWithIdentifier(Constants.Segues.goToProfileView, sender: user)
    }
    
    // reload data (from TimelineController)
    func reloadDataForDisplay() {
        homeTableView.reloadData()
    }

    
    // MARK: Notification Handlers
    func createdNewTweet(notice: NSNotification) {
        if let dict = notice.userInfo as? Dictionary<String, AnyObject> {
            if let tweet = dict["tweet"] as? Tweet {
                // adding new tweet
                print("adding new tweet")
                timelineController.tweets.insert(tweet, atIndex:0)
            }
            
        }
    }
    
}
