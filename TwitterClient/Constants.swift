//
//  Constants.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//


// utility class to store various string constants
class Constants {
    
    class Segues {
        static let loginToHomeTimelineSegueName = "loginToHomeTimeline"
        static let composeTweetSegueName = "composeTweetSegue"
        static let sentTweetSegueName = "sentTweetSegue"
        static let tweetDetailReturnToTimeline = "tweetDetailReturnTimeline"
        static let goToTweetDetailSegue = "goToTweetDetail"
        static let replyToTweetSegue = "replyToTweetSegue"
    }

    class Storyboards {
        static let homeTimelineStoryboardName = "HomeTimeline"
        static let composeTweetStoryboardName = "composeTweet"
    }
    
    class TableCells {
        static let homeTimelinePrototypeCellName = "HomelineTableViewCell"
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
    }
}