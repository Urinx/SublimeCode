//
//  CustomServer.swift
//  Sublime
//
//  Created by Eular on 3/10/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation
import Swifter

extension HttpHandlers {
    public class func shareFilesFromDirectory(directoryPath: String, serverLog: WebServerLog?) -> (HttpRequest -> HttpResponse) {
        return { r in
            guard let fileRelativePath = r.params.first else {
                serverLog?.log(r, statusCode: 404)
                return Page404()
            }
            let absolutePath = directoryPath + "/" + fileRelativePath.1
            guard let file = try? Swifter.File.openForReading(absolutePath) else {
                serverLog?.log(r, statusCode: 404)
                serverLog?.log("Error: Read file failed", isError: true)
                return Page404()
            }
            serverLog?.log(r, statusCode: 200)
            return .RAW(200, "OK", [:], { writer in
                var buffer = [UInt8](count: 64, repeatedValue: 0)
                while let count = try? file.read(&buffer) where count > 0 {
                    writer.write(buffer[0..<count])
                }
                file.close()
            })
        }
    }
    
    public class func Page404() -> HttpResponse {
        let html = NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("Web/404", ofType: "html")!)!
        var array = [UInt8](count: html.length, repeatedValue: 0)
        html.getBytes(&array, length: html.length)
        return .RAW(200, "OK", nil, { $0.write(array) })
    }
}

public func CustomServer(serverLog: WebServerLog?) -> HttpServer {
    let server = HttpServer()
    let publicDir = Folder(path: Constant.SublimeRoot+"/var/www")
    
    server["/:path"] = HttpHandlers.shareFilesFromDirectory(publicDir.path, serverLog: serverLog)
    
    server["/"] = { r in
        if let html = NSData(contentsOfFile:"\(publicDir.path)/index.html") {
            serverLog?.log(r)
            var array = [UInt8](count: html.length, repeatedValue: 0)
            html.getBytes(&array, length: html.length)
            return HttpResponse.RAW(200, "OK", nil, { $0.write(array) })
        } else {
            serverLog?.log(r, statusCode: 404)
            return HttpHandlers.Page404()
        }
    }
    
    return server
}
