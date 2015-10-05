//
//  HomeTimelineViewController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeTimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Outlets
    @IBOutlet weak var homeTableHeaderView: UIView!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    // MARK: data
    var tweets  = [Tweet]() {
        didSet {
            homeTableView.reloadData()
        }
    }
    
    // MARK: hacks
    var refreshControl : UIRefreshControl!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: Constants.Notifications.tweetCreated, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // table setup
        homeTableView.delegate = self
        homeTableView.dataSource = self
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
        
        
        // notification of new tweets
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "createdNewTweet:", name: Constants.Notifications.tweetCreated, object: nil)


        fetchHomeTimeline()
    }
    
 
    func fetchHomeTimeline() {
        // get home timeline
        Twitter.homeTimeline(nil) { (tweets, error) -> Void in
            if error == nil {
                self.tweets = tweets!
                self.refreshControl.endRefreshing()
                self.printRateStatus()
            }else{
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.homeTimelinePrototypeCellName, forIndexPath: indexPath) as! HomelineTableViewCell
        
       // cell.selectionStyle = .None
        cell.tweet = tweets[indexPath.row]
        
        if( indexPath.row == (tweets.count-1)){
            printRateStatus()
        }
        
        return cell
    }
    
    // MARK: Actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == Constants.Segues.goToTweetDetailSegue {
            if let cell = sender as? HomelineTableViewCell {
                if let indexPath = homeTableView.indexPathForCell(cell) {
                    let detailVC = segue.destinationViewController as! TweetDetailViewController
                    detailVC.holderTweet = tweets[indexPath.row]
                }
            }
        }
    }
    
    func createdNewTweet(notice: NSNotification) {
        if let dict = notice.userInfo as? Dictionary<String, AnyObject> {
            if let tweet = dict["tweet"] as? Tweet {
                // adding new tweet
                print("adding new tweet")
                tweets.insert(tweet, atIndex:0)
            }
        
        }
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
    @IBAction func composeTweetTapped(sender: AnyObject) {
        performSegueWithIdentifier(Constants.Segues.composeTweetSegueName, sender: self)
    }
  
    /*
    @IBAction func unwindToHomeTimeline(sender: UIStoryboardSegue) {
        if let sourceVC = sender.sourceViewController as? ComposeTweetViewController {
            if let tweet = sourceVC.tweet {
                let destinationVC = sender.destinationViewController as! HomeTimelineViewController
                destinationVC.tweets.insert(tweet, atIndex: 0)
            }
        }
    }
    */
    
    // MARK: rate status print
    private var ratePrintLabels = ["/statuses/home_timeline":"home timeline", "/statuses/retweets/:id":"retweet"]
    func printRateStatus() {
        // print rate status
        Twitter.getRateStatuses() { (json: JSON?, error: NSError?) -> Void in
            if error == nil, let json = json {
                for (key,value) in self.ratePrintLabels {
                    let dict = json["resources"]["statuses"][key]
                    let limit = dict["limit"].intValue
                    let remaining = dict["remaining"].intValue
                    let epoch = dict["reset"].intValue
                    let resetDate = NSDate(timeIntervalSince1970: Double(epoch))
                    print("\(value) rate: limit=\(limit), remaining=\(remaining); expires in \(Tweet.formatIntervalElapsed(resetDate.timeIntervalSinceNow))")
                }
            }else{
                print("error getting rate status: \(error)")
            }
        }
    }

}
