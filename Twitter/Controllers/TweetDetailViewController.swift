//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by john on 3/5/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit

@objc protocol TweetDetailViewControllerDelegate {
    @objc optional func didLikeStateChange(vc: TweetDetailViewController)
    @objc optional func didTweetStateChange(vc: TweetDetailViewController)
}

class TweetDetailViewController: UIViewController {
    
    @IBOutlet weak var tblTweetDetail: UITableView!
    
    var selectedTweet: Tweet!
    var indexOfTweet: Int!
    
    var delegate: AddingTweetViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tblTweetDetail.dataSource = self
        tblTweetDetail.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TweetDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedTweet.reply.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : selectedTweet.reply.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetCell
        cell.delegate = self
        
        switch indexPath.section {
        case 0:
            cell.tweet = selectedTweet
            return cell
        case 1:
            cell.tweet = selectedTweet.reply[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension TweetDetailViewController: TweetCellDelegate {
    func reply(cell: TweetCell) {
        performSegue(withIdentifier: Constant.Indentifier_Segue_Reply, sender: nil)
    }
    
    func like(cell: TweetCell) {
        GuiUtils.showLoadingIndicator()
        
        selectedTweet.isFavorited = cell.tweet.isFavorited
        selectedTweet.favoritesCount = cell.tweet.favoritesCount
        
        cell.btnLike.imageView?.image = cell.tweet.isFavorited ? #imageLiteral(resourceName: "yourLike") : #imageLiteral(resourceName: "othersLike")
        
        tblTweetDetail.reloadData()
        GuiUtils.dismissLoadingIndicator()
        
        // TODO nil exception @here
        // delegate.didLikeStateChange!(vc: self)
    }
    
    func tweet(cell: TweetCell) {
        GuiUtils.showLoadingIndicator()
        selectedTweet.isRetweeted = cell.tweet.isRetweeted
        selectedTweet.retweetCount = cell.tweet.retweetCount
        cell.btnRetweet.imageView?.image = cell.tweet.isRetweeted ? #imageLiteral(resourceName: "reTweeted") : #imageLiteral(resourceName: "reTweet")
        
        tblTweetDetail.reloadData()
        GuiUtils.dismissLoadingIndicator()
        
        // TODO nil exception @here
        //delegate.didTweetStateChange!(vc: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Indentifier_Segue_Reply {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! AddingTweetViewController
            
            vc.tweet = selectedTweet
            vc.index = indexOfTweet
            vc.delegate = self
        }
    }
}

extension TweetDetailViewController: AddingTweetViewControllerDelegate {
    func didReplyingTweet(addingTweet tweet: Tweet, index: Int) {
        selectedTweet.reply.append(tweet)
        tblTweetDetail.reloadData()
    }
}
