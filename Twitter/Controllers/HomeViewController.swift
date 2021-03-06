//
//  HomeViewController.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tblHome: UITableView!
    
    let refreshControl = UIRefreshControl()
    
    var isLoadingMore = false
    
    var loadingMoreView: InfiniteLoadingView!
    
    var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblHome.dataSource = self
        tblHome.delegate = self
        
        tblHome.rowHeight = UITableViewAutomaticDimension
        tblHome.estimatedRowHeight = 200
        
        // infinite scroll
        let frame = CGRect(x: 0, y: 0, width: tblHome.bounds.size.width, height: InfiniteLoadingView.defaultHeight)
        loadingMoreView = InfiniteLoadingView(frame: frame)
        tblHome.tableFooterView = loadingMoreView
        loadingMoreView.startAnimating()
        
        // pull to refresh
        refreshControl.addTarget(self, action: #selector(loadData), for: UIControlEvents.valueChanged)
        tblHome.addSubview(refreshControl)
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        TwitterClientUtils.shared.requestSerializer.removeAccessToken()
        Yours.shared = nil
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        appDelegate.window?.rootViewController = nextVC
    }
    
}

// MARK: - Load data functions
extension HomeViewController {
    func loadData() {
        TwitterClientUtils.shared.homeTimeline(count: nil, maxId: nil, success: { (tweets) in
            self.tweets = tweets
            self.tblHome.reloadData()
            self.refreshControl.endRefreshing()
        },  failure: { (error) in
            self.refreshControl.endRefreshing()
            self.showErrorAlert(title: error.localizedDescription)
        })
    }
    
    func loadMoreTweet() {
        let maxId = tweets[tweets.count - 1].id! - 1
        TwitterClientUtils.shared.homeTimeline(count: nil, maxId: maxId, success: { (tweets) in
            self.tweets += tweets
            self.isLoadingMore = false
            self.loadingMoreView!.stopAnimating()
            self.tblHome.reloadData()
        }) { (error) in
            self.isLoadingMore = false
            self.loadingMoreView!.stopAnimating()
        }
    }
}

// MARK: - Setup UITableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.Indentifier_Segue_Detail, sender: self)
    }
}

// MARK: - Delegate processing
extension HomeViewController: TweetCellDelegate {
    
    func like(cell: TweetCell) {
        GuiUtils.showLoadingIndicator()
        let ip = tblHome.indexPath(for: cell)
        
        tweets[(ip?.row)!].isFavorited = cell.tweet.isFavorited
        tweets[(ip?.row)!].favoritesCount = cell.tweet.favoritesCount
        
        //cell.btnLike.imageView?.image = cell.tweet.isFavorited ? #imageLiteral(resourceName: "yourLike") : #imageLiteral(resourceName: "othersLike")
        
        tblHome.reloadRows(at: [ip!], with: .fade)
        GuiUtils.dismissLoadingIndicator()
    }
    
    func reply(cell: TweetCell) {
        let ip = tblHome.indexPath(for: cell)
        let data = [cell.tweet, ip?.row as AnyObject] as [AnyObject]
        performSegue(withIdentifier: Constant.Indentifier_Segue_Reply, sender: data)
    }
    
    func tweet(cell: TweetCell) {
        GuiUtils.showLoadingIndicator()
        let ip = tblHome.indexPath(for: cell)
        
        tweets[(ip?.row)!].isRetweeted = cell.tweet.isRetweeted
        tweets[(ip?.row)!].retweetCount = cell.tweet.retweetCount
        
        //cell.btnRetweet.imageView?.image = cell.tweet.isRetweeted ? #imageLiteral(resourceName: "reTweeted") : #imageLiteral(resourceName: "reTweet")
        
        tblHome.reloadRows(at: [ip!], with: .none)
        GuiUtils.dismissLoadingIndicator()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constant.Indentifier_Segue_Reply {
            let data = sender as! [AnyObject]
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! AddingTweetViewController
            vc.tweet = data[0] as? Tweet
            vc.index = data[1] as? Int
            vc.delegate = self
        } else if segue.identifier == Constant.Indentifier_Segue_New {
            let nc = segue.destination as! UINavigationController
            let vc = nc.topViewController as! AddingTweetViewController
            vc.delegate = self
        } else if segue.identifier == Constant.Indentifier_Segue_Detail {
            let nextVc = segue.destination as! TweetDetailViewController
            nextVc.selectedTweet = tweets[(tblHome.indexPathForSelectedRow?.row)!]
            nextVc.indexOfTweet = tblHome.indexPathForSelectedRow?.row
        }
    }
}

extension HomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isLoadingMore) {
            let scrollViewContentHeight = tblHome.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tblHome.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tblHome.isDragging) {
                isLoadingMore = true
                loadingMoreView!.startAnimating()
                loadMoreTweet()
            }
        }
    }
}

extension HomeViewController: AddingTweetViewControllerDelegate {
    
    func didAddingTweet(addingTweet tweet: Tweet) {
        tweets.insert(tweet, at: 0)
        tblHome.reloadData()
    }
    
    func didReplyingTweet(addingTweet tweet: Tweet, index: Int) {
        tweets[index].reply.append(tweet)
    }
}

extension HomeViewController: TweetDetailViewControllerDelegate {
    func didLikeStateChange(vc: TweetDetailViewController) {
        let ip = IndexPath(row: vc.indexOfTweet, section: 0)
        
        tweets[(ip.row)].isFavorited = vc.selectedTweet.isFavorited
        tweets[(ip.row)].favoritesCount = vc.selectedTweet.favoritesCount
        
        tblHome.reloadRows(at: [ip], with: .fade)
    }
    
    func didTweetStateChange(vc: TweetDetailViewController) {
        let ip = IndexPath(row: vc.indexOfTweet, section: 0)
        
        tweets[(ip.row)].isRetweeted = vc.selectedTweet.isRetweeted
        tweets[(ip.row)].retweetCount = vc.selectedTweet.retweetCount
        
        tblHome.reloadRows(at: [ip], with: .fade)
    }
}
