//
//  Tweet.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import Foundation
import NSDate_TimeAgo

class Tweet: NSObject {
    var id: Int?
    var text: String?
    var createdAt: Date?
    var retweetCount: Int?
    var favoritesCount: Int?
    var user: Yours?
    var isRetweeted = false
    var isFavorited = false
    var imageUrls = [URL]()
    var replyId: Int?
    var reply = [Tweet]()
    var dictionary: NSDictionary?
    var timeStamp: String {
        return (createdAt as NSDate?)?.timeAgo() ?? Constant.Empty_String
    }
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        id = dictionary["id"] as? Int
        text = dictionary["text"] as? String
        
        if let timestampString = dictionary["created_at"] as? String {
            let timeFormater = DateFormatter()
            timeFormater.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = timeFormater.date(from: timestampString)
        }
        
        retweetCount = dictionary["retweet_count"] as? Int! ?? 0
        favoritesCount = dictionary["favorite_count"] as? Int! ?? 0
        user = dictionary["user"] != nil ? Yours(dictionary: (dictionary["user"] as? NSDictionary)!) : nil
        isFavorited = (dictionary["favorited"] as? Bool!) ?? false
        isRetweeted = (dictionary["retweeted"] as? Bool!) ?? false
        
        if let media = dictionary.value(forKeyPath: "extended_entities.media") as? [NSDictionary] {
            for image in media {
                if let urlString = image["media_url_https"] as? String {
                    imageUrls.append(URL(string: "\(urlString):medium")!)
                }
            }
        }
        
        replyId = dictionary["in_reply_to_status_id"] as? Int
    }
    
    class func tweetsArray(dictionarys: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dictionarys {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}
