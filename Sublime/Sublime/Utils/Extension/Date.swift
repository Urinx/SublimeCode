//
//  Date.swift
//  Sublime
//
//  Created by Eular on 4/25/16.
//  Copyright © 2016 Eular. All rights reserved.
//

import Foundation

enum TimeIntervalUnit {
    case Seconds, Minutes, Hours, Days, Months, Years
    
    func dateComponents(interval: Int) -> NSDateComponents {
        let components = NSDateComponents()
        
        switch (self) {
        case .Seconds:
            components.second = interval
        case .Minutes:
            components.minute = interval
        case .Hours:
            components.hour = interval
        case .Days:
            components.day = interval
        case .Months:
            components.month = interval
        case .Years:
            components.year = interval
        }
        return components
    }
}

struct TimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    var ago: NSDate {
        let calendar = NSCalendar.currentCalendar()
        let today = NSDate()
        let components = unit.dateComponents(-self.interval)
        return calendar.dateByAddingComponents(components, toDate: today, options: .WrapComponents)!
    }
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

extension Int {
    var seconds: TimeInterval {
        return TimeInterval(interval: self, unit: .Seconds)
    }
    
    var minutes: TimeInterval {
        return TimeInterval(interval: self, unit: .Minutes)
    }
    
    var hours: TimeInterval {
        return TimeInterval(interval: self, unit: .Hours)
    }
    
    var days: TimeInterval {
        return TimeInterval(interval: self, unit: .Days)
    }
    
    var months: TimeInterval {
        return TimeInterval(interval: self, unit: .Months)
    }
    
    var years: TimeInterval {
        return TimeInterval(interval: self, unit: .Years)
    }
}

extension NSDate {
    class func yesterday() -> NSDate {
        return NSDate() - 1.days
    }
    
    func toS(format: String) -> String? {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
}

extension String {
    func toDate(format: String = "dd/MM/yyyy") -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone()
        formatter.dateFormat = format
        return formatter.dateFromString(self)
    }
    
    func toGMTDate(format: String = "dd/MM/yyyy") -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter.dateFromString(self)
    }
}

func + (left: NSDate, right: TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: .WrapComponents)!
}

func - (left: NSDate, right: TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = right.unit.dateComponents(-right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: .WrapComponents)!
}

func < (left: NSDate, right: NSDate) -> Bool {
    let result: NSComparisonResult = left.compare(right)
    var isEarlier = false
    if (result == NSComparisonResult.OrderedAscending) {
        isEarlier = true
    }
    return isEarlier
}

func - (left: NSDate, right: NSDate) -> NSDateComponents {
    let diffDateComponents = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: right, toDate: left, options: NSCalendarOptions.init(rawValue: 0))
    return diffDateComponents
}
