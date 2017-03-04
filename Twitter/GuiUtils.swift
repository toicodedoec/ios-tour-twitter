//
//  GuiUtils.swift
//  Twitter
//
//  Created by john on 3/5/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import Foundation
import SVProgressHUD

class GuiUtils {
    
    class func showLoadingIndicator() {
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.setForegroundColor(UIColor.cyan)
        SVProgressHUD.show()
    }
    
    class func dismissLoadingIndicator() {
        SVProgressHUD.dismiss()
    }
}
