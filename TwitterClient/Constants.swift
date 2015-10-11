//
//  Constants.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import SwiftyJSON

// utility class to store various string constants
class Constants {
    
    class Segues {
        static let loginToHomeTimeline = "loginToHomeTimeline"
        static let timelineToComposeTweet = "timelineToComposeTweetSegue"
        static let sentTweetSegueName = "sentTweetSegue"
        static let tweetDetailReturnToTimeline = "tweetDetailReturnTimeline"
        static let goToTweetDetail = "goToTweetDetail"
        static let replyToTweet = "replyToTweetSegue"
        static let goToProfileView = "timelineToProfile"
        static let userProfileToCompose = "userProfileToCompose"
        static let tweetDetailToProfile = "tweetDetailToProfile"
        static let userProfileToTweetDetail = "profileToTweetDetail"
    }

    class Storyboards {
        static let timelineStoryboardName = "Timeline"
        static let composeTweetStoryboardName = "composeTweet"
        static let profileStoryboardName = "UserProfile"
    }
    
    class TableCells {
        static let timelinePrototypeCellName = "TimelineTableViewCell"
        static let hamburgerTableCellName = "HamburgerTableCell"
        static let twitterBurgersCellName = "TwitterBurgerTableViewCell"
    }
    
    class Colors {
        static let Blue = UIColor(red:0.33, green:0.67, blue:0.93, alpha:1.0)
        static let Black = UIColor(red:0.16, green:0.18, blue:0.20, alpha:1.0)
        static let DarkGrey = UIColor(red:0.40, green:0.46, blue:0.50, alpha:1.0)
        static let MedGrey = UIColor(red:0.80, green:0.84, blue:0.87, alpha:1.0)
        static let LightGrey = UIColor(red:0.88, green:0.91, blue:0.93, alpha:1.0)
    }
    
    class Notifications {
        static let userDidLogoutNotification = "userDidLogoutNotification"
        static let userDidLoginNotification = "userDidLoginNotification"
        static let tweetCreated = "userDidCreateTweet"
    }
    
    class TwitterParams {
        static let tweetText = "status"
        static let replyToStatus = "in_reply_to_status_id"
    }
    
    class Sizes {
        static let UserProfileHeaderHeightMax = CGFloat(128.0)
        static let UserProfileHeaderHeightMin = CGFloat(64.0)
        static let HamburgerMenuVisibleWidth = CGFloat(248.0)
    }
}

class Helpers {
    
    // MARK: rate status print
    private static let ratePrintLabels = [
        "/statuses/home_timeline":"home timeline",
        "/statuses/retweets/:id":"retweet",
        "/statuses/user_timeline":"user timeline"]
    
    static func printRateStatus() {
        // print rate status
        Twitter.getRateStatuses() { (json: JSON?, error: NSError?) -> Void in
            if error == nil, let json = json {
                for (key,value) in Helpers.ratePrintLabels {
                    let dict = json["resources"]["statuses"][key]
                    let limit = dict["limit"].intValue
                    let remaining = dict["remaining"].intValue
                    let epoch = dict["reset"].intValue
                    let resetDate = NSDate(timeIntervalSince1970: Double(epoch))
                    print("\(value) rate: limit=\(limit), remaining=\(remaining); expires in \(Helpers.formatIntervalElapsed(resetDate.timeIntervalSinceNow))")
                }
            }else{
                print("error getting rate status: \(error)")
            }
        }
    }
    
    // MARK: convert number to condensed text
    static let condensedNumberLabels = [ "", "K", "M", "B" ]
    static func formatNumberAsCondensed(amount : Int) -> String {
        var factor : Double = 1.0
        var currentAmt : Double = Double(amount)
        var index = 0
        while currentAmt > 1000.0 {
            factor = factor * 1000.0
            currentAmt = currentAmt/factor
            index++
        }
        
        let nf = NSNumberFormatter()
        nf.maximumSignificantDigits = 3
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 0
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        let newAmount = Double(amount)/factor
        let retString = nf.stringFromNumber(newAmount)! + Helpers.condensedNumberLabels[index]
        return retString
    }
    
    // MARK: time formatting; to display elapsed time as "2d" or "1w" ... etc
    private static var elapsedTimeFormatter: NSDateComponentsFormatter = {
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = NSDateComponentsFormatterUnitsStyle.Abbreviated
        formatter.collapsesLargestUnit = true
        formatter.maximumUnitCount = 1
        return formatter
    }()
    
    static func formatTimeElapsed(sinceDate: NSDate) -> String {
        let interval = NSDate().timeIntervalSinceDate(sinceDate)
        return elapsedTimeFormatter.stringFromTimeInterval(interval)!
    }
    
    static func formatIntervalElapsed(interval: NSTimeInterval) -> String {
        return elapsedTimeFormatter.stringFromTimeInterval(interval)!
    }
    
}