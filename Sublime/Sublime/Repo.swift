//
//  Repo.swift
//  Sublime
//
//  Created by Eular on 5/9/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Repo {
    var id: String!
    var name: String!
    var description: String!
    var ownerLogin: String!
    var url: String!
    var stargazers: Int!
    var forks: Int!
    var watchers: Int!
    var language: String!
    var issues: Int!
    var size: Double!
    var created_at: String!
    var downloadFolder: Folder?
    var downloadZipPath: String = ""
    
    required init(json: JSON) {
        self.description = json["description"].string
        self.id = json["id"].string
        self.name = json["name"].string
        self.ownerLogin = json["owner"]["login"].string
        self.url = json["url"].string
        self.stargazers = json["stargazers_count"].int
        self.forks = json["forks_count"].int
        self.watchers = json["watchers_count"].int
        self.language = json["language"].string
        self.issues = json["open_issues_count"].int
        self.size = json["size"].double
        self.created_at = json["created_at"].string
    }
    
    func fatchReadmeFile(format: String = "raw", completion: (String) -> Void) {
        let url = "https://api.github.com/repos/\(ownerLogin)/\(name)/readme"
        let header = ["Accept": "application/vnd.github.VERSION.\(format)"]
        
        Alamofire.request(.GET, url, headers: header).responseString { response in
            if let str = response.result.value {
                let metafix = "<meta name=\"viewport\" content=\"width=device-width,initial-scale=0.8,maximum-scale=0.8,user-scalable=no\"/>"
                let cssfix = "<style type=\"text/css\">body{background-color:#515151;color:#fff}article{margin:0 10px}svg path{fill:#fff}table{width: 100%;border-collapse:collapse}table,td,th{border:1px solid #253238}td,th{padding:5px}a{color:#00AFF4}h1:after,h2:after{margin-top:10px;content:' ';display:block;border:.5px solid gray}code{color:pink}pre{padding:10px;word-wrap:break-word;background-color:#253238}pre>code{color:#fff}</style>"
                switch format {
                case "raw":
                    completion(str)
                case "html":
                    completion(metafix+str+cssfix)
                default:
                    completion(str)
                }
                
            }
        }
    }
    
    func download(duration: ((Int64, Int64, Int64) -> Void)? = nil, completion: (() -> Void)? = nil, failed: (() -> Void)? = nil) {
        let url = "https://api.github.com/repos/\(ownerLogin)/\(name)/zipball/master"
        
        Alamofire.download(.GET, url) { temporaryURL, response in
            let pathComponent = response.suggestedFilename
            let downloadUrl: NSURL!
            if let url = self.downloadFolder?.url {
                downloadUrl = url.URLByAppendingPathComponent(pathComponent!)
            } else {
                let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
                downloadUrl = directoryURL.URLByAppendingPathComponent(pathComponent!)
            }
            self.downloadZipPath = downloadUrl.path!
            return downloadUrl
            }.progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                Log("Total bytes read: \(totalBytesRead)")
                if let d = duration { d(bytesRead, totalBytesRead, totalBytesExpectedToRead) }
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                // dispatch_async(dispatch_get_main_queue()) {
                //    print("Total bytes read on main queue: \(totalBytesRead)")
                // }
            }.response { _, _, _, error in
                if let error = error {
                    Log("Download failed with error: \(error)")
                    if let f = failed { f() }
                } else {
                    Log("Downloaded file successfully")
                    let zipFile = File(path: self.downloadZipPath)
                    zipFile.unzip(keepFile: false)
                    Log("Unzip file successfully")
                    if let c = completion { c() }
                }
        }
    }
}