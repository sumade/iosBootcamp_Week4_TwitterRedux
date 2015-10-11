//
//  TweetsTimelineController.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/10/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol TimelineControllerReloadDelegate {
    func reloadDataForDisplay()
}

protocol TimelineScrollDelegate {
    func willBeginScrolling(scrollView: UIScrollView)
    func didScroll(scrollView: UIScrollView)
}

class TimelineController : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: data
    var tweets  = [Tweet]() {
        didSet {
            reloadDelegate.reloadDataForDisplay()
        }
    }
    
    // MARK: reload delegate
    var reloadDelegate: TimelineControllerReloadDelegate!
    
    // MARK: profileVC delegate
    var profileViewDelegate : ShowProfileDelegate!
    
    // MARK: scroll delegate
    var scrollDelegate : TimelineScrollDelegate?
    
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
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableCells.timelinePrototypeCellName, forIndexPath: indexPath) as! TimelineTableViewCell
        
        // cell.selectionStyle = .None
        cell.tweet = tweets[indexPath.row]
        
        // set profile delegate
        cell.showProfileDelegate = profileViewDelegate
        
        // if last row, print rate status
        if( indexPath.row == (tweets.count-1)){
            Helpers.printRateStatus()
        }
        
        return cell
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if let scrollDelegate = self.scrollDelegate {
            scrollDelegate.willBeginScrolling(scrollView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let scrollDelegate = self.scrollDelegate {
            scrollDelegate.didScroll(scrollView)
        }
    }
}

