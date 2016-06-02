//
//  RSSFeed.swift
//  AlamofireRSSParser
//
//  Created by Donald Angelillo on 3/1/16.
//  Copyright © 2016 Donald Angelillo. All rights reserved.
//

import Foundation

/**
    RSS gets deserialized into an instance of `RSSFeed`.  Top-level RSS elements are housed here.
    
    Item-level elements are deserialized into `RSSItem` objects and stored in the `items` property.
*/
public class RSSFeed: CustomStringConvertible {
    public var title: String? = nil
    public var link: String? = nil
    public var feedDescription: String? = nil
    public var pubDate: NSDate? = nil
    public var lastBuildDate: NSDate? = nil
    public var language: String? = nil
    public var copyright: String? = nil
    public var managingEditor: String? = nil
    public var webMaster: String? = nil
    public var generator: String? = nil
    public var docs: String? = nil
    public var ttl: NSNumber? = nil
    
    public var items: [RSSItem] = Array()
    
    public var description: String {
        return "title: \(self.title)\nfeedDescription: \(self.feedDescription)\nlink: \(self.link)\npubDate: \(self.pubDate)\nlastBuildDate: \(self.lastBuildDate)\nlanguage: \(self.language)\ncopyright: \(self.copyright)\nmanagingEditor: \(self.managingEditor)\nwebMaster: \(self.webMaster)\ngenerator: \(self.generator)\ndocs: \(self.docs)\nttl: \(self.ttl)\nitems: \n\(self.items)"
    }
    
}