//
//  SublimeServer.swift
//  Sublime
//
//  Created by Eular on 3/10/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import Swifter
import SwiftyJSON

public func SublimeServer(serverLog: WebServerLog?) -> HttpServer {
    let server = HttpServer()
    let webDir = NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent("Web")
    
    server["/file_manager/:path"] = HttpHandlers.shareFilesFromDirectory(webDir, serverLog: serverLog)
    server["/file_manager"] = { r in
        serverLog?.log(r, statusCode: 301)
        return .MovedPermanently("/file_manager/index.html")
    }
    
    server["/"] = { r in
        serverLog?.log(r, statusCode: 301)
        return .MovedPermanently("/file_manager/index.html")
    }
    
    server["/json/:param"] = { r in
        serverLog?.log(r)
        
        var json = ["code": 200, "filelist": []]
        var filelist = [NSObject]()
        if r.params[":param"] == "filelist" {
            for (key, value) in r.queryParams {
                if key == "path" {
                    let folder = Folder(path: NSHomeDirectory()+"/Documents"+value)
                    for f in folder.listFiles() {
                        var type = "unknown"
                        if f.isImg {
                            type = "image"
                        } else {
                            switch f.img {
                                case "folder": type = "folder"
                                case "file_unknown": type = "unknown"
                                default: type = "file"
                            }
                        }
                        filelist.append(["name": f.name, "type": type])
                    }
                }
            }
        }
        json["filelist"] = filelist
        
        return .OK(.Json(json))
    }
    
    return server
}