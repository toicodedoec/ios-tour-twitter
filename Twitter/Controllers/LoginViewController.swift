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
                SVProgressHUD.dismiss()
                Yours.shared = user
                self.performSegue(withIdentifier: "showLogin", sender: self)
            })
        }, failure: { (error) in
            print(error.localizedDescription)
        })
    }
    
}

