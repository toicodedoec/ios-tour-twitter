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
    var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tblHome.dataSource = self
        tblHome.delegate = self
        
        tblHome.rowHeight = UITableViewAutomaticDimension
        tblHome.estimatedRowHeight = 200
        
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
        })
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
        return cell
    }
    
    
}
