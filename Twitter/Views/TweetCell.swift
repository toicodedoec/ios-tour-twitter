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
    func like(cell: TweetCell)
    func tweet(cell: TweetCell)
    func reply(cell: TweetCell)
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
            lblTime.text = "\(tweet.createdAtString(short: true))"
            lblPostContent.text = tweet.text
            lblRetweetCounting.text = tweet.retweetCount! > 0 ? "\(tweet.retweetCount!)" : "0"
            lblLikeCounting.text = tweet.favoritesCount! > 0 ? "\(tweet.favoritesCount!)" : "0"
            
            btnRetweet.imageView?.image = tweet.isRetweeted ? #imageLiteral(resourceName: "reTweeted") : #imageLiteral(resourceName: "reTweet")
            btnLike.imageView?.image = tweet.isFavorited ? #imageLiteral(resourceName: "yourLike") : #imageLiteral(resourceName: "othersLike")
            
            lblRetweetCounting.sizeToFit()
            lblLikeCounting.sizeToFit()
            
            if tweet.imageUrls.count > 0 {
                /*
                let uiImgPostView = UIImageView()
                
                 uiImgPostView.autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
                 uiImgPostView.contentMode = .scaleAspectFill
                 uiImgPostView.clipsToBounds = true
 
                uiImgPostView.setImageWith(tweet.imageUrls[0], placeholderImage: #imageLiteral(resourceName: "loading"))
                
                imgPostView.addSubview(uiImgPostView)
                uiImgPostView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                imgPostView.layer.borderColor = UIColor.cyan.cgColor
                imgPostView.layer.borderWidth = 1
                imgPostViewHeightConstraint.constant = 150
                */
                heightCons.constant = 150
                imgPostContent.setImageWith(tweet.imageUrls[0], placeholderImage: #imageLiteral(resourceName: "loading"))
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
        
    }
    
    @IBAction func like(_ sender: UIButton) {
        TwitterClientUtils.shared.processingLikeState(id: tweet.id!, isFavorited: tweet.isFavorited, success: { (t) in
            self.tweet.isFavorited = t.isFavorited
            self.tweet.favoritesCount = t.favoritesCount
            self.delegate.like(cell: self)
        })
    }
    
    @IBAction func retweet(_ sender: UIButton) {
        TwitterClientUtils.shared.processingRetweetState(id: tweet.id!, isTweeted: tweet.isRetweeted, success: { (t) in
            self.tweet.isRetweeted = t.isRetweeted
            self.tweet.retweetCount = t.retweetCount
            self.delegate.tweet(cell: self)
        })
    }
}
