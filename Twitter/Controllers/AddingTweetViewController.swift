//
//  AddingTweetViewController.swift
//  Twitter
//
//  Created by john on 3/5/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import UIKit

@objc protocol AddingTweetViewControllerDelegate {
    func didReplyingTweet(addingTweet tweet: Tweet, index: Int)
    func didAddingTweet(addingTweet tweet: Tweet)
}

class AddingTweetViewController: UIViewController {
    @IBOutlet weak var imgAvatar: UIImageView!
    
    @IBOutlet weak var txtContent: UITextView!
    @IBOutlet weak var lblCountdownChar: UILabel!
    @IBOutlet weak var btnPost: UIButton!
    @IBOutlet weak var consBottom: NSLayoutConstraint!
    @IBOutlet weak var btnHash: UIButton!
    @IBOutlet weak var btnAttach: UIButton!
    @IBOutlet weak var btnLink: UIButton!
    
    var isOk: Bool = false;
    var tweet: Tweet?
    var index: Int?
    var delegate: AddingTweetViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let avatarUrl = Yours.shared?.profileImageUrl {
            imgAvatar.setImageWith(avatarUrl)
        }
        
        if let tweet = tweet {
            navigationItem.title = "Reply"
            btnPost.setTitle("Reply", for: .disabled)
            btnPost.setTitle("Reply", for: .normal)
            //replyTitle.text = "Reply to \(tweet.user!.name!)"
            //replyTitleContainer.isHidden = false
            txtContent.text = "@\(tweet.user!.screenname!) "
        }
        
        // Do any additional setup after loading the view.
        btnPost.isEnabled = isOk
        btnHash.isEnabled = true
        btnLink.isEnabled = true
        btnAttach.isEnabled = true
        
        txtContent.delegate = self
        txtContent.becomeFirstResponder()
        
        // register noti/tap for keyboard
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        tapToDimissKeyboard()
    }
    
    @IBAction func hash(_ sender: UIButton) {
        txtContent.text = "#"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func post(_ sender: UIButton) {
        if isOk {
            GuiUtils.showLoadingIndicator()
            dismissKeyboard()
            if let tweet = tweet {
                TwitterClientUtils.shared.processingAddTweet(content: txtContent.text, replyId: tweet.replyId ?? tweet.id, success: { (t) in
                    self.delegate.didReplyingTweet(addingTweet: t, index: self.index!)
                    GuiUtils.dismissLoadingIndicator()
                    self.dismiss(animated: true, completion: nil)
                }, failure: {(error) -> Void in
                    GuiUtils.dismissLoadingIndicator()
                })
            } else {
                TwitterClientUtils.shared.processingAddTweet(content: txtContent.text, replyId: 1000, success: { (t) in
                    // TODO: why it throws [fatal error: unexpectedly found nil while unwrapping an Optional value] @here
                    self.delegate.didAddingTweet(addingTweet: t)
                    GuiUtils.dismissLoadingIndicator()
                    self.dismiss(animated: true, completion: nil)
                }, failure: {(error) -> Void in
                    GuiUtils.dismissLoadingIndicator()
                })
            }
        }
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        txtContent.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddingTweetViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        isOk = textView.text.characters.count <= Constant.Length_Of_Post
        btnPost.isEnabled = isOk
        lblCountdownChar.text = "\(Constant.Length_Of_Post - textView.text.characters.count)"
        print(lblCountdownChar.textColor)
        lblCountdownChar.textColor = isOk ? lblCountdownChar.textColor : UIColor.red
    }
}

extension AddingTweetViewController {
    
    func adjustInsetForKeyboardShow(notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.cgRectValue
        consBottom.constant = keyboardFrame.height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(notification: notification)
    }
    
    func tapToDimissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        consBottom.constant = 0
        view.endEditing(true)
    }
}

// MARK: -Toolbar functions
extension AddingTweetViewController {
    
}
