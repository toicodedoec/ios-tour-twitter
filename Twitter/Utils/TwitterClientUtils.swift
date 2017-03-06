//
//  TwitterClientUtils.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

class TwitterClientUtils: BDBOAuth1SessionManager {
    static var shared = TwitterClientUtils(baseURL: URL(string: "https://api.twitter.com")!, consumerKey: "8pheut7KeZ4uUk9f4Rgij0BhI", consumerSecret: "7Fly9qwg3XbjR80wmnwyFrS7wbVw6yGGSWjPFmdiWfKIkOCeAK")!
    
    private var _accessToken: BDBOAuth1Credential?
    var accessToken: BDBOAuth1Credential? {
        get{
            if _accessToken == nil {
                _accessToken = StorageUtils.shared.loadAccessToken()
                if let at = _accessToken, !at.isExpired {
                    requestSerializer.saveAccessToken(_accessToken)
                } else {
                    _accessToken = nil
                }
            }
            return _accessToken
        }
        set(new){
            _accessToken = new
            StorageUtils.shared.saveAccessToken(accessToken: _accessToken)
        }
    }
    
    private var loginSuccess: (() -> Void)?
    private var loginFailure: ((Error) -> Void)?
    
    func login(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "com.toicodedoec.Twitter://oauth"), scope: nil, success: { (token) in
            let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token!.token!)")!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }, failure: { (error) in
            failure(error!)
        })
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (access_token) in
            print("\(access_token?.secret)\n\(access_token?.token)")
            self.accessToken = access_token
            self.loginSuccess?()
        }) { (error) in
            self.loginFailure?(error!)
        }
    }
    
    func homeTimeline(count: Int?, maxId: Int?,success: @escaping ([Tweet]) -> Void, failure: ((Error) -> Void)? = nil) {
        
        var parameters = [String : AnyObject]()
        
        parameters["exclude_replies"] = true as AnyObject
        
        parameters["count"] = count != nil ? count! as AnyObject : 22 as AnyObject
        
        if maxId != nil {
            parameters["max_id"] = maxId! as AnyObject
        }
        
        get("1.1/statuses/home_timeline.json", parameters: parameters, progress: nil, success: { (task, response) in
            let tweets: [Tweet]
            if let dictionaries = response as? [NSDictionary] {
                print(dictionaries)
                tweets = Tweet.tweetsArray(dictionarys: dictionaries)
            } else {
                tweets = [Tweet]()
            }
            
            success(tweets)
        }) { (task, error) in
            print("Get homeTimeline data failed \(error.localizedDescription)")
            failure?(error)
        }
    }
    
    func currentAccount(success: @escaping (Yours) -> Void) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task, response) in
            let userDictionary = response as! NSDictionary
            let user = Yours(dictionary: userDictionary)
            success(user)
        }) { (task, error) in
            self.loginFailure?(error)
        }
    }
    
    func processingLikeState(id: Int, isFavorited: Bool, success: @escaping (Tweet) -> Void, failure: ((Error) -> Void)? = nil) {
        var params = [String: AnyObject]()
        params["id"] = id as AnyObject
        
        let url: String = isFavorited ? "1.1/favorites/destroy.json" : "1.1/favorites/create.json"
        post(url, parameters: params, progress: nil, success: { (task, response) -> Void in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }, failure: { (task, error) -> Void in
            print("Like/unlike tweet error: \(error.localizedDescription)")
            failure?(error)
        })
    }
    
    func processingRetweetState(id: Int, isTweeted: Bool, success: @escaping (Tweet) -> Void, failure: ((Error) -> Void)? = nil) {
        let url = !isTweeted ? "1.1/statuses/retweet/\(id).json" : "1.1/statuses/unretweet/\(id).json"
        
        post(url, parameters: nil, progress: nil, success: { (task, response) -> Void in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }, failure: { (task, error) -> Void in
            print("Retweeting error: \(error.localizedDescription)")
            failure?(error)
        })
    }
    
    // new tweet
    func processingAddTweet(content: String, replyId: Int?, success: @escaping (Tweet) -> Void, failure: ((Error) -> Void)? = nil) {
        var params = [String: AnyObject]()
        params["status"] = content as AnyObject
        
        if let replyId = replyId {
            params["in_reply_to_status_id"] = replyId as AnyObject
        }
        
        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (task, response) -> Void in
            let dictionary = response as! NSDictionary
            let tweet = Tweet(dictionary: dictionary)
            success(tweet)
        }, failure: { (task, error) -> Void in
            print("Adding tweet/reply error: \(error.localizedDescription)")
            failure?(error)
        })
    }
}

