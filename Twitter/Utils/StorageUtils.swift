//
//  StorageUtils.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

class StorageUtils {
    static let shared = StorageUtils()
    
    private let defaults = UserDefaults.standard
    private let userKey = "user"
    private let accessTokenKey = "accessToken"
    
    func saveUser(yours: Yours?) {
        if let user = yours {
            let data = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
            defaults.set(data, forKey: userKey)
        } else {
            defaults.set(nil, forKey: userKey)
        }
        defaults.synchronize()
    }
    
    func loadUser() -> Yours? {
        var user: Yours?
        if let data = defaults.object(forKey: userKey) as? Data {
            let dictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
            user = Yours(dictionary: dictionary)
        }
        
        return user
    }
    
    func saveAccessToken(accessToken: BDBOAuth1Credential?) {
        if let accessToken = accessToken {
            let data = NSKeyedArchiver.archivedData(withRootObject: accessToken)
            defaults.set(data, forKey: accessTokenKey)
        } else {
            defaults.set(nil, forKey: accessTokenKey)
        }
        defaults.synchronize()
    }
    
    func loadAccessToken() -> BDBOAuth1Credential? {
        var accessToken: BDBOAuth1Credential?
        if let data = defaults.object(forKey: accessTokenKey) as? Data {
            accessToken = NSKeyedUnarchiver.unarchiveObject(with: data) as? BDBOAuth1Credential
        }
        
        return accessToken
    }
}
