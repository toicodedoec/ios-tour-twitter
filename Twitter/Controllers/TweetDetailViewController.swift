//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by john on 3/5/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {
    
    @IBOutlet weak var tblTweetDetail: UITableView!
    var tweet: Tweet!
    
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
        return tweet.reply.count > 0 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : tweet.reply.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell") as! TweetCell
        cell.delegate = self
        
        switch indexPath.section {
        case 0:
            cell.tweet = tweet
            return cell
        case 1:
            cell.tweet = tweet.reply[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension TweetDetailViewController: TweetCellDelegate {
    func reply(cell: TweetCell) {
        
    }
}
