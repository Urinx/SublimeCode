//
//  Gist.swift
//  Sublime
//
//  Created by Eular on 5/9/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

struct Gist {
    var url: String
    var ownerLogin: String
    var description: String
    var avatar_url: String
    var comments: Int
    var created_at: String
    var files: [[String: String]] = []
    
    init(json: JSON) {
        self.url = json["url"].string ?? ""
        self.description = json["description"].string ?? ""
        self.ownerLogin = json["owner"]["login"].string  ?? ""
        self.avatar_url = json["owner"]["avatar_url"].string  ?? ""
        self.comments = json["comments"].int ?? 0
        
        let time = json["created_at"].string?.replace("T", " ").replace("Z", "") ?? ""
        self.created_at = time
        
        for (key, value) in json["files"] {
            var t: [String: String] = [:]
            t["raw_url"] = value["raw_url"].string
            t["size"] = value["size"].string
            t["language"] = value["language"].string
            t["filename"] = key
            self.files << t
        }
    }
    
    func getRawData(completion: ((content: String) -> Void)? = nil) {
        let url = self.files[0]["raw_url"]!
        Alamofire.request(.GET, url).responseString { response in
            guard let content = response.result.value else { return }
            completion?(content: content)
        }
    }
}