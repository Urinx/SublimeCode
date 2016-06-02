//
//  RSSItem.swift
//  AlamofireRSSParser
//
//  Created by Donald Angelillo on 3/1/16.
//  Copyright © 2016 Donald Angelillo. All rights reserved.
//

import Foundation

/**
    Item-level elements are deserialized into `RSSItem` objects and stored in the `items` array of an `RSSFeed` instance
*/
public class RSSItem: CustomStringConvertible {
    public var title: String? = nil
    public var link: String? = nil
    
    /**
        Upon setting this property the `itemDescription` will be scanned for HTML and all image urls will be extracted and stored in `imagesFromDescription`
     */
    public var itemDescription: String? = nil {
        didSet {
            if let itemDescription = self.itemDescription {
                self.imagesFromDescription = self.imagesFromHTMLString(itemDescription)
            }
        }
    }
    
    public var guid: String? = nil
    public var author: String? = nil
    public var comments: String? = nil
    public var source: String? = nil
    public var pubDate: NSDate? = nil
    public var mediaThumbnail: String? = nil;
    public var mediaContent: String? = nil;
    public var imagesFromDescription: [String]? = nil;

    public var description: String {
        return "\ttitle: \(self.title)\n\tlink: \(self.link)\n\titemDescription: \(self.itemDescription)\n\tguid: \(self.guid)\n\tauthor: \(self.author)\n\tcomments: \(self.comments)\n\tsource: \(self.source)\n\tpubDate: \(self.pubDate)\nmediaThumbnail: \(self.mediaThumbnail)\nmediaContent: \(self.mediaContent)\nimagesFromDescription: \(self.imagesFromDescription)\n\n"
    }
    
    
    /**
        Retrieves all the images (\<img\> tags) from a given String contaning HTML using a regex.
        
        - Parameter htmlString: A String containing HTML
     
        - Returns: an array of image url Strings ([String])
     */
    private func imagesFromHTMLString(htmlString: String) -> [String] {
        let htmlNSString = htmlString as NSString;
        var images: [String] = Array();
        
        do {
            let regex = try NSRegularExpression(pattern: "(https?)\\S*(png|jpg|jpeg|gif)", options: [NSRegularExpressionOptions.CaseInsensitive])
        
            regex.enumerateMatchesInString(htmlString, options: [NSMatchingOptions.ReportProgress], range: NSMakeRange(0, htmlString.characters.count)) { (result, flags, stop) -> Void in
                if let range = result?.range {
                    images.append(htmlNSString.substringWithRange(range))  //because Swift ranges are still completely ridiculous
                }
            }
        }
        
        catch {
            
        }
        
        return images;
    }
}