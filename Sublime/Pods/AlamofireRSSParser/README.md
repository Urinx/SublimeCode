# AlamofireRSSParser

[![CI Status](http://img.shields.io/travis/AdeptusAstartes/AlamofireRSSParser.svg?style=flat)](https://travis-ci.org/AdeptusAstartes/AlamofireRSSParser)
[![Version](https://img.shields.io/cocoapods/v/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)
[![License](https://img.shields.io/cocoapods/l/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)
[![Platform](https://img.shields.io/cocoapods/p/AlamofireRSSParser.svg?style=flat)](http://cocoapods.org/pods/AlamofireRSSParser)

## Requirements
- Xcode 7.2+
- Alamofire 3.0.0 or higher

**Note:** Version 1.0.1 currently locks the Alamofire dependency at ~> 3.2.1 because for some misguided reason the Alamofire Foundation decided to force us to use Xcode 7.3 in order to use Alamofire 3.3.0.

## Installation

### Cocoapods
AlamofireRSSParser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "AlamofireRSSParser"
```

Then 

```swift
import AlamofireRSSParser
``` 
 wherever you're using it.
 

### Manually
Alternately you can add the contents of AlamofireRSSParser/Pod/Classes/ to your project and import the classes as appropriate.

## Usage

_Note: To run the example project, clone the repo, and run `pod install` from the Example directory first._

You use AlamofireRSSParser just like any other response handler in Alamofire:

```swift
let url = "http://rss.cnn.com/rss/cnn_topstories.rss"
    
Alamofire.request(.GET, url).responseRSS() { (response) -> Void in
    if let feed: RSSFeed = response.result.value {
        //do something with your new RSSFeed object!
        for item in feed.items {
            print(item)
        }
    }
}
```

AlamofireRSSParser returns an RSSFeed object that contains an array of RSSItem objects.

##What It Does and Doesn't Do

I think we can all admit that RSS implementations are a bit all over the place.  This project is meant to parse all of the common, high level bits of the [RSS 2.0 spec](http://cyber.law.harvard.edu/rss/rss.html) that people actually use/care about.  It is not meant to comprehensively parse **all** RSS.

RSS 2.0 spec elements that it currently parses:

- title
- link
- itemDescription
- guid
- author
- comments
- source
- pubDate

In addition, since this is a Swift port of what was originally the backbone of [Heavy Headlines](https://itunes.apple.com/us/app/heavy-headlines-metal-news/id623879550?mt=8) it also parses portions of the [Media RSS Specification 1.5.1](http://www.rssboard.org/media-rss).  

Current elements:

- media:content
- media: thumbnail

It also yanks all of the images that may be linked in the `itemDescription` (if it's HTML) and creates a nice array named `imagesFromDescription` that you can use for more image content.


If you need more elements parsed please file an issue or even better, **please contribute**!  That's why this is on GitHub.


## Author

Don Angelillo, dangelillo@gmail.com

Inspired by Thibaut LE LEVIER's awesome orginal [Block RSSParser](https://github.com/tibo/BlockRSSParser) AFNetworking Plugin. 

## License

AlamofireRSSParser is available under the MIT license. See the LICENSE file for more info.
