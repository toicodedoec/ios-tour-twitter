//
//  Yours.swift
//  Twitter
//
//  Created by john on 3/1/17.
//  Copyright © 2017 toicodedoec. All rights reserved.
//

import Foundation

class Yours: NSObject {
    
    private static var _shared: Yours?
    
    static var shared: Yours? {
        get {
            if _shared == nil {
                _shared = StorageUtils.shared.loadUser()
            }
            return _shared
        }
        
        set(new) {
            _shared = new
            StorageUtils.shared.saveUser(yours: _shared)
        }
    }
    
    var name: String?
    var screenname: String?
    var profileImageUrl: URL?
    var tagline: String?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        
        if let profileImageUrlString = dictionary["profile_image_url_https"] as? String {
            profileImageUrl = URL(string: profileImageUrlString)
        }
        
        tagline = dictionary["description"] as? String
    }
}
