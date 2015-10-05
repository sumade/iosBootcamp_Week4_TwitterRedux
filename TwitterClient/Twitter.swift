//
//  TwitterAPIClient.swift
//  TwitterClient
//
//  Created by Sumeet Shendrikar on 10/3/15.
//  Copyright © 2015 Sumeet Shendrikar. All rights reserved.
//

import BDBOAuth1Manager
import SwiftyJSON

protocol TwitterLoginHandler {
    func loginCompletion() -> Void
    func loginFailure(error: NSError?) -> Void
}

class Twitter  {
    private class LimitStatus {
        static let RateExceeded = 429
        static let TweetExceeded = 403
    }
    
    private class MahStrings {
        // oauth related
        static let consumerKey = "epRoEMHd8sD2wQUrx1IkuQ6KY"
        static let consumerSecret = "ZigovbldQc8VcMS42qQmTXpisEbca4tDJ7YkdCSVLzOL8YrBER"
        static let baseUrl = "https://api.twitter.com"
        static let requestTokenPath = "oauth/request_token"
        static let authUrl = baseUrl + "/oauth/authorize?oauth_token="
        static let accessTokenPath = "oauth/access_token"
        static let callbackUrl = "doh://oauth"
        
        // resource related
        static let userInfo = "1.1/account/verify_credentials.json"
        static let homeTimeline = "1.1/statuses/home_timeline.json"
        static let rateStatus = "1.1/application/rate_limit_status.json?resources=statuses"//,favorites"
        static let sendNewTweet = "1.1/statuses/update.json"
        static let favoriteTweet = "1.1/favorites/create.json" // needs ?id=
        static let unfavoriteTweet = "1.1/favorites/destroy.json" // needs ?id=
        static let retweetTweet = "1.1/statuses/retweet/" //  retweet/id.json
        static let favoritesList = "1.1/favorites/list.json"
    }
    
    private static let oauthMgr = BDBOAuth1RequestOperationManager(baseURL: NSURL(string: MahStrings.baseUrl)!, consumerKey: MahStrings.consumerKey, consumerSecret: MahStrings.consumerSecret)
    
    private static var myHandler : TwitterLoginHandler?
    
        
    static func login(handler: TwitterLoginHandler?) {
        // remove access token
        oauthMgr.requestSerializer.removeAccessToken()
        myHandler = handler
        oauthMgr.fetchRequestTokenWithPath(MahStrings.requestTokenPath, method: "GET", callbackURL: NSURL(string:MahStrings.callbackUrl)!, scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: "\(MahStrings.authUrl)\(requestToken.token)" )!)
            },
            failure: { (error: NSError!) -> Void in
                myHandler?.loginFailure(error)
        })
    }
    
    static func openUrl(url : NSURL) {
        oauthMgr.fetchAccessTokenWithPath(MahStrings.accessTokenPath, method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                oauthMgr.requestSerializer.saveAccessToken(accessToken)
                
                // get the current user
                oauthMgr.GET(MahStrings.userInfo, parameters: nil,
                    success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                        // store the user
                        User.currentUser = User.createUser(JSON(response))
                        myHandler?.loginCompletion()
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        // got an error
                        myHandler?.loginFailure(error)
                })
                
            },
            failure: { (error: NSError!) -> Void in
                myHandler?.loginFailure(error)
        })
    }
    
    static func reset() {
        oauthMgr.requestSerializer.removeAccessToken()
    }
    
    static func homeTimeline(params: NSDictionary?, completion: ((tweets: [Tweet]?, error: NSError?) -> Void)) {
        let actualParams : NSMutableDictionary = [:]
        if let params = params {
            if params.count > 0 {
                actualParams.addEntriesFromDictionary(params as [NSObject : AnyObject])
            }
        }
        
        if actualParams.valueForKey("count") == nil {
            actualParams["count"] = 200
        }
        
//        let foo = actualParams.valueForKey("count") as! Int
//        print("\(foo)")
        
        
        oauthMgr.GET(MahStrings.homeTimeline, parameters:actualParams,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(tweets: Tweet.createTweets(JSON(response).array!), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if operation.response.statusCode == LimitStatus.RateExceeded {
                    let expirationEpoch = operation.response.allHeaderFields["x-rate-limit-reset"] as! String
                    let expirationDate = NSDate(timeIntervalSince1970: Double(Int(expirationEpoch)!))
                    print("home timeline rate limit exceeded! rate limit expires in \(Tweet.formatIntervalElapsed(expirationDate.timeIntervalSinceNow))")
                }
                completion(tweets: nil, error: error)
            })
    }
    
    static func sendTweet(tweet: String, params: NSDictionary?, completion: ((tweet: Tweet?, error: NSError?) -> Void)) {
        oauthMgr.POST(MahStrings.sendNewTweet, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(tweet: Tweet.createTweet(JSON(response)), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if operation.response.statusCode == LimitStatus.TweetExceeded {
                    print("too many tweets sent!")
                    print("error is: \(error)")
                }
                completion(tweet: nil, error: error)
            })
    }
    
    static func favoritesList( params: NSDictionary?, completion: ((tweets: [Tweet]?, error: NSError?) -> Void )) {
        let actualParams : NSMutableDictionary = [:]
        if let params = params {
            if params.count > 0 {
                actualParams.addEntriesFromDictionary(params as [NSObject : AnyObject])
            }
        }
        
        if actualParams.valueForKey("count") == nil {
            actualParams["count"] = 200
        }

        oauthMgr.GET(MahStrings.favoritesList, parameters: actualParams,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(tweets: Tweet.createTweets(JSON(response).array!), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if operation.response.statusCode == LimitStatus.RateExceeded {
                    let expirationEpoch = operation.response.allHeaderFields["x-rate-limit-reset"] as! String
                    let expirationDate = NSDate(timeIntervalSince1970: Double(Int(expirationEpoch)!))
                    print("favorites list rate limit exceeded! rate limit expires in \(Tweet.formatIntervalElapsed(expirationDate.timeIntervalSinceNow))")
                }
                completion(tweets: nil, error: error)
        })
    }
    
    static func favoriteTweet(tweet: Tweet, completion: ((tweet: Tweet?, error: NSError?) -> Void)) {
        let params: NSMutableDictionary = ["id": tweet.idStr!]
        
        oauthMgr.POST(MahStrings.favoriteTweet, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(tweet: Tweet.createTweet(JSON(response)), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if operation.response.statusCode == LimitStatus.RateExceeded {
                    let expirationEpoch = operation.response.allHeaderFields["x-rate-limit-reset"] as! String
                    let expirationDate = NSDate(timeIntervalSince1970: Double(Int(expirationEpoch)!))
                    print("favorite tweet rate limit exceeded! rate limit expires in \(Tweet.formatIntervalElapsed(expirationDate.timeIntervalSinceNow))")
                }else if operation.response.statusCode == LimitStatus.TweetExceeded {
                    // already favorited tweet, no error
                    return
                }
                completion(tweet: nil, error: error)
        })
    }

    static func unfavoriteTweet(tweet: Tweet, completion: ((tweet: Tweet?, error: NSError?) -> Void)) {
        let params: NSMutableDictionary = ["id": tweet.idStr!]
        
        oauthMgr.POST(MahStrings.unfavoriteTweet, parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(tweet: Tweet.createTweet(JSON(response)), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if operation.response.statusCode == LimitStatus.RateExceeded {
                    let expirationEpoch = operation.response.allHeaderFields["x-rate-limit-reset"] as! String
                    let expirationDate = NSDate(timeIntervalSince1970: Double(Int(expirationEpoch)!))
                    print("unfavorite tweet rate limit exceeded! rate limit expires in \(Tweet.formatIntervalElapsed(expirationDate.timeIntervalSinceNow))")
                }
                completion(tweet: nil, error: error)
        })
    }
    
    
    static func retweetTweet(tweet: Tweet, completion: ((tweet: Tweet?, error: NSError?) -> Void)) {
        let url = MahStrings.retweetTweet + tweet.idStr! + ".json"
        
        oauthMgr.POST(url, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                completion(tweet: Tweet.createTweet(JSON(response)), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                if operation.response.statusCode == LimitStatus.RateExceeded {
                    let expirationEpoch = operation.response.allHeaderFields["x-rate-limit-reset"] as! String
                    let expirationDate = NSDate(timeIntervalSince1970: Double(Int(expirationEpoch)!))
                    print("retweet tweet rate limit exceeded! rate limit expires in \(Tweet.formatIntervalElapsed(expirationDate.timeIntervalSinceNow))")
                }
                completion(tweet: nil, error: error)
        })
        
    }

    static func replyTweet(tweet: Tweet, completion: ((error: NSError?) -> Void)) {
        
    }

    static func getRateStatuses(handler: ((response: JSON?, error: NSError?) -> Void)) {
        oauthMgr.GET(MahStrings.rateStatus, parameters:nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                handler(response: JSON(response), error:nil)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                print("error getting rate statuses: \(error)")
                handler(response:nil, error: error)
            })
    }
    
}
