//
//  User.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import Foundation
import SwiftyJSON

class User : NSObject {
    
    // MARK: Constants
    private class JSONKeys {
        static let idStr = "id_str"
        static let name = "name"
        static let profileImageURL = "profile_image_url"
        static let profileImageHttpsURL = "profile_image_url_https"
        static let screenName = "screen_name"
        static let verified = "verified"
    }
    
    private static let persistedKeyName = "TWITTER.CURRENT_USER"
    
    // MARK: properties
    private(set) var idStr : String?
    private(set) var name : String?
    private(set) var profileImageURL : String?
    private(set) var profileImageHttpsURL : String?
    private(set) var screenName : String?
    private(set) var verified : Bool = false
    
    private var dictionary : JSON? {
        didSet {
            if let json = dictionary {
                self.idStr = json[JSONKeys.idStr].string
                self.name = json[JSONKeys.name].string
                self.screenName = json[JSONKeys.screenName].string
                self.verified = json[JSONKeys.verified].boolValue
                self.profileImageURL = json[JSONKeys.profileImageURL].string?.stringByReplacingOccurrencesOfString("_normal.jpg", withString: "_bigger.jpg")
                self.profileImageHttpsURL = json[JSONKeys.profileImageHttpsURL].string?.stringByReplacingOccurrencesOfString("_normal.jpg", withString: "_bigger.jpg")
            }else{
                // TODO: clear the user info
            }
        }
    }
 
    // hide the default initializer for now
    private override init() {
        
    }
    
    // User factory
    // TODO: error handling if values not present
    static func createUser(dictionary: JSON) -> User {
        let newUser = User()
        newUser.dictionary = dictionary
        return newUser
    }
    
    // MARK: current user
    // TODO: error handling
    private static var _currentUser : User? = nil
    static var currentUser : User? {
        get {
            if _currentUser == nil {
                // check if persisted data available
                if let data = NSUserDefaults.standardUserDefaults().objectForKey(User.persistedKeyName) as? NSData {
                    _currentUser = User()
                    _currentUser!.dictionary = JSON(data: data)
                    print("recovered current user \(_currentUser!.name)")
                    //_currentUser!.getFavoritedTweets()
                }
            }

            return _currentUser
        }
        
        set(user) {
            _currentUser = user
            
            if let user = user {
                // persist current user
                if let data = try? user.dictionary?.rawData() {
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: User.persistedKeyName)
                    //_currentUser!.getFavoritedTweets()
                }
                _currentUser!.favTweets = []
            }else{
                // clear current user
                NSUserDefaults.standardUserDefaults().removeObjectForKey(User.persistedKeyName)
            }

            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func logout() {
        User.currentUser = nil
        Twitter.reset()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notifications.userDidLogoutNotification, object: nil)
    }
    
    private var favTweets : [String] = []
    private var currentFavMaxId = ""
    
    private var counter : Int = 0
    // TODO: this only works for the last 200 tweets... needs to periodically refresh the favorites list
    func getFavoritedTweets() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) {
            let params : NSMutableDictionary = [:]
            if !self.currentFavMaxId.isEmpty {
                    params["max_id"] = self.currentFavMaxId
            }
            Twitter.favoritesList(params, completion: { (tweets, error) -> Void in
            if error == nil {
                if tweets!.count > 1 {
                    if let tweets = tweets {
                        let ids = tweets.map{ $0.idStr! }
                        self.favTweets.appendContentsOf(ids)
                        if let newMax = tweets[tweets.count-1].idStr {
                            self.currentFavMaxId = newMax
                            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "getFavoritedTweets", userInfo: nil, repeats: false)
                        }
                    }
                } // otherwise, done
            }else{
                // don't care
            }
            })
        }
    }
    
    func didFavoriteTweet(idStr: String) -> Bool {
        return favTweets.indexOf{ $0 == idStr } != nil
    }
    
    /*
    func addFavorite(idStr: String) {
        favTweets.append(idStr)
    }
    
    func removeFavorite(idStr: String) {
        favTweets = favTweets.filter{ $0 != idStr }
    }
    */
    
}