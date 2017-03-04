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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func loadData() {
        TwitterClientUtils.shared.homeTimeline(count: nil, maxId: nil, success: { (tweets) in
            self.tweets = tweets
            self.tblHome.reloadData()
            self.refreshControl.endRefreshing()
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
    
    @IBAction func logOut(_ sender: UIBarButtonItem) {
        TwitterClientUtils.shared.requestSerializer.removeAccessToken()
        Yours.shared = nil
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        appDelegate.window?.rootViewController = nextVC
    }
    
}

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
}

extension HomeViewController: TweetCellDelegate {
    func like(cell: TweetCell) {
        let ip = tblHome.indexPath(for: cell)
        
        tweets[(ip?.row)!].isFavorited = cell.tweet.isFavorited
        tweets[(ip?.row)!].favoritesCount = cell.tweet.favoritesCount
        
        cell.btnLike.imageView?.image = cell.tweet.isFavorited ? #imageLiteral(resourceName: "yourLike") : #imageLiteral(resourceName: "othersLike")
        
        tblHome.reloadRows(at: [ip!], with: .fade)
    }
    
    func reply(cell: TweetCell) {
        
    }
    
    func tweet(cell: TweetCell) {
        let ip = tblHome.indexPath(for: cell)
        
        tweets[(ip?.row)!].isRetweeted = cell.tweet.isRetweeted
        tweets[(ip?.row)!].retweetCount = cell.tweet.retweetCount
        
        cell.btnRetweet.imageView?.image = cell.tweet.isRetweeted ? #imageLiteral(resourceName: "reTweeted") : #imageLiteral(resourceName: "reTweet")
        
        tblHome.reloadRows(at: [ip!], with: .none)
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

