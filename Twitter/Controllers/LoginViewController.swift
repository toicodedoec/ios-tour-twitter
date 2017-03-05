//
//  ViewController.swift
//  Twitter
//
//  Created by john on 2/27/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var imgLogin: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imgLogin.isUserInteractionEnabled = true
        imgLogin.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        GuiUtils.showLoadingIndicator()
        TwitterClientUtils.shared.login(success: {
            TwitterClientUtils.shared.currentAccount(success: { (user) in
                GuiUtils.dismissLoadingIndicator()
                Yours.shared = user
                self.performSegue(withIdentifier: "showLogin", sender: self)
            })
        }, failure: { (error) in
            GuiUtils.dismissLoadingIndicator()
            self.showErrorAlert(title: error.localizedDescription, retry: {
                TwitterClientUtils.shared.requestSerializer.removeAccessToken()
                Yours.shared = nil
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                appDelegate.window?.rootViewController = nextVC
            })
        })
    }
    
}

extension UIViewController {
    func showErrorAlert(title: String, retry: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: "Do you want to Retry or Exit?", preferredStyle: .alert)
        let exit = UIAlertAction(title: "Exit", style: .cancel) { (alert: UIAlertAction!) -> Void in
            UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
        let retry = UIAlertAction(title: "Retry", style: .default) { (alert: UIAlertAction!) -> Void in
            if let retry = retry {
                retry()
            }
        }
        
        alert.addAction(exit)
        alert.addAction(retry)
        
        present(alert, animated: true, completion: nil)
    }
}

