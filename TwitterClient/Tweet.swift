//
//  Tweet.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import Foundation
import SwiftyJSON

class Tweet : NSObject {
    
    // MARK: Constants
    private class JSONKeys {
        static let createdDateString = "created_at"
        static let favoriteCount = "favorite_count"
        static let favorited = "favorited"
        static let idStr = "id_str"
        static let inReplyToStatusIdStr = "in_reply_to_status_id_str"
        static let inReplyToUserIdStr = "in_reply_to_user_id_str"
        static let retweetCount = "retweet_count"
        static let retweeted = "retweeted"
        static let text = "text"
        static let user = "user"
        static let retweetedStatus = "retweeted_status"
    }
    
    // MARK: Properties
    private(set) var createdDateString : String?
    private(set) var createdDate : NSDate?
    private(set) var sinceDateString : String?
    private(set) var favoriteCount : Int = 0
    private(set) var favorited : Bool = false
    private(set) var idStr : String?
    private(set) var inReplyToStatusIdStr : String?
    private(set) var inReplyToUserIdStr : String?
    private(set) var retweetCount : Int = 0
    private(set) var retweeted : Bool =  false
    private(set) var text : String?
    private(set) var user : User?
    private(set) var retweet : Tweet?
    

    private static var twitterDateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        return formatter
    }()
    
    private var dictionary : JSON? {
        didSet {
            if let json = dictionary {
                self.createdDateString = json[JSONKeys.createdDateString].string
                self.favoriteCount = json[JSONKeys.favoriteCount].intValue
                self.favorited = json[JSONKeys.favorited].boolValue
                self.idStr = json[JSONKeys.idStr].string
                self.inReplyToStatusIdStr = json[JSONKeys.inReplyToStatusIdStr].string
                self.inReplyToUserIdStr = json[JSONKeys.inReplyToUserIdStr].string
                self.retweetCount = json[JSONKeys.retweetCount].intValue
                self.retweeted = json[JSONKeys.retweeted].boolValue
                self.text = json[JSONKeys.text].string
                self.user = User.createUser(json[JSONKeys.user])
                
                createdDate = Tweet.twitterDateFormatter.dateFromString(self.createdDateString!)
                self.sinceDateString = Tweet.formatTimeElapsed(self.createdDate!)
                
                if json[JSONKeys.retweetedStatus] != nil {
                    retweet = Tweet.createTweet(json[JSONKeys.retweetedStatus])
                }
            }else{
                // TODO: clear the tweet info
            }
        }
    }
    
    // hide the default initializer for now
    private override init() {
    }
    
    // Tweet factory
    // TODO: error handling if values not present
    static func createTweet(dictionary: JSON) -> Tweet {
        let newTweet = Tweet()
        newTweet.dictionary = dictionary
        return newTweet
    }
    
    // MARK: create array from dictionary array
    static func createTweets(array: [JSON]) -> [Tweet] {
        return array.map{ Tweet.createTweet($0) }
    }
    
    
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
    
    func retweet(completion: ((error: NSError?) -> Void)) {
        Twitter.retweetTweet(self) { (tweet, error) -> Void in
            if error == nil {
                self.favoriteCount = tweet!.favoriteCount
                self.retweetCount = tweet!.retweetCount
                self.retweeted = true
                completion(error: nil)
            }else{
                print("error retweeting tweet \(self.idStr): \(error)")
                completion(error:error)
            }
        }
    }
    
    func unretweet() {
        
    }
    
    func favorite(completion: ((error: NSError?) -> Void)) {
        Twitter.favoriteTweet(self, completion: { (tweet, error) -> Void in
            if error == nil {
                self.favorited = true
                self.favoriteCount = tweet!.favoriteCount
                self.retweetCount = tweet!.retweetCount
   //             User.currentUser!.addFavorite(self.idStr!)
                completion(error:nil)
            }else{
                print("error favoriting tweet \(self.idStr): \(error)")
                completion(error:error)
            }
        })
    }
    
    func unfavorite(completion: ((error: NSError?) -> Void)) {
        Twitter.unfavoriteTweet(self, completion: { (tweet, error) -> Void in
            if error == nil {
                self.favorited = false
                self.favoriteCount = tweet!.favoriteCount
                self.retweetCount = tweet!.retweetCount
    //            User.currentUser!.removeFavorite(self.idStr!)
                completion(error:nil)
            }else{
                print("error unfavoriting tweet \(self.idStr): \(error)")
                completion(error:error)
            }
        })
    }
    
}