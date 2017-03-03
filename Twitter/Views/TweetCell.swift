//
//  TweetCell.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit
import SnapKit


class TweetCell: UITableViewCell {
    
    @IBOutlet weak var lblAccount: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPostContent: UILabel!
    @IBOutlet weak var imgPost: UIView!
    @IBOutlet weak var lblRetweetCounting: UILabel!
    @IBOutlet weak var lblLikeCounting: UILabel!
    
    @IBOutlet weak var imgRetweet: UIImageView!
    @IBOutlet weak var imgLike: UIImageView!
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var imgPostView: UIView!
    @IBOutlet weak var imgPostViewHeightConstraint: NSLayoutConstraint!
    
    var tweet: Tweet! {
        didSet {
            
            if let avatarUrl = tweet.user?.profileImageUrl {
                imgAvatar.setImageWith(avatarUrl, placeholderImage: #imageLiteral(resourceName: "loading"))
            }
            
            lblAccount.text = tweet.user?.name
            lblName.text = tweet.user?.screenname
            lblTime.text = "\(tweet.createdAtString(short: true))"
            lblPostContent.text = tweet.text
            lblRetweetCounting.text = tweet.retweetCount! > 0 ? "\(tweet.retweetCount!)" : ""
            lblLikeCounting.text = tweet.favoritesCount! > 0 ? "\(tweet.favoritesCount!)" : ""
            
            imgPostViewHeightConstraint.constant = 0
            
            if tweet.imageUrls.count > 0 {
                /*
                let uiImgPostView = UIImageView()
                
                uiImgPostView.frame.size.width = imgPostView.frame.size.width
                uiImgPostView.frame.size.height = 150
                
                uiImgPostView.autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin, .flexibleWidth]
                uiImgPostView.contentMode = .scaleAspectFill
                uiImgPostView.clipsToBounds = true
                
                uiImgPostView.setImageWith(tweet.imageUrls[0], placeholderImage: #imageLiteral(resourceName: "loading"))
                
                imgPostView.addSubview(uiImgPostView)
                
                let verConstraint = NSLayoutConstraint(item: uiImgPostView, attribute: .top, relatedBy: .equal,
                                                       toItem: imgPostView, attribute: .top,
                                                       multiplier: 1.0, constant: 0.0)
                
                imgPostView.addConstraint(verConstraint)
                imgPostView.layer.borderColor = UIColor.black.cgColor
                imgPostView.layer.borderWidth = 1
                
                imgPostViewHeightConstraint.constant = 150
                */
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

    
}
