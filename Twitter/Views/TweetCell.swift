//
//  TweetCell.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit
import SnapKit

@objc protocol TweetCellDelegate {
    @objc optional func like(cell: TweetCell)
    @objc optional func tweet(cell: TweetCell)
    @objc optional func reply(cell: TweetCell)
}

class TweetCell: UITableViewCell {
    
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPostContent: UILabel!
    @IBOutlet weak var lblRetweetCounting: UILabel!
    @IBOutlet weak var lblLikeCounting: UILabel!
    
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgPostView: UIView!
    @IBOutlet weak var imgPostViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnRetweet: UIButton!
    
    @IBOutlet weak var imgPostContent: UIImageView!
    
    @IBOutlet weak var heightCons: NSLayoutConstraint!
    
    var delegate: TweetCellDelegate!
    
    @IBOutlet weak var tweetCellContentView: UIView!
    var tweet: Tweet! {
        didSet {
            
            if let avatarUrl = tweet.user?.profileImageUrl {
                imgAvatar.setImageWith(avatarUrl, placeholderImage: #imageLiteral(resourceName: "loading"))
            }
            
            lblAccount.text = tweet.user?.name
            lblName.text = tweet.user?.screenname
            lblTime.text = "\(tweet.timeStamp)"
            lblPostContent.text = tweet.text
            lblRetweetCounting.text = tweet.retweetCount! > 0 ? "\(tweet.retweetCount!)" : "0"
            lblLikeCounting.text = tweet.favoritesCount! > 0 ? "\(tweet.favoritesCount!)" : "0"
            
            btnRetweet.setImage((tweet.isRetweeted ? #imageLiteral(resourceName: "reTweeted") : #imageLiteral(resourceName: "reTweet")), for: .normal)
            btnLike.setImage((tweet.isFavorited ? #imageLiteral(resourceName: "yourLike") : #imageLiteral(resourceName: "othersLike")), for: .normal)
            
            lblRetweetCounting.sizeToFit()
            lblLikeCounting.sizeToFit()
            lblTime.sizeToFit()
            lblAccount.sizeToFit()
            
            lblName.isHidden = true
            
            if tweet.imageUrls.count > 0 {
                heightCons.constant = 150
                imgPostContent.setImageWith(tweet.imageUrls[0], placeholderImage: #imageLiteral(resourceName: "icon"))
            } else {
                heightCons.constant = 0
                tweetCellContentView.willRemoveSubview(imgPostContent)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func reply(_ sender: UIButton) {
        delegate.reply!(cell: self)
    }
    
    @IBAction func like(_ sender: UIButton) {
        TwitterClientUtils.shared.processingLikeState(id: tweet.id!, isFavorited: tweet.isFavorited, success: { (t) in
            self.tweet.isFavorited = t.isFavorited
            self.tweet.favoritesCount = t.favoritesCount
            self.delegate.like!(cell: self)
        })
    }
    
    @IBAction func retweet(_ sender: UIButton) {
        TwitterClientUtils.shared.processingRetweetState(id: tweet.id!, isTweeted: tweet.isRetweeted, success: { (t) in
            self.tweet.isRetweeted = t.isRetweeted
            self.tweet.retweetCount = t.retweetCount
            self.delegate.tweet!(cell: self)
        })
    }
}
