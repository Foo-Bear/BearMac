//
//  ScheduleManager.swift
//  BearMac
//
//  Created by Jonathan Solomon on 12/17/15.
//  Copyright © 2015 FooBear. All rights reserved.
//

import Cocoa

class ScheduleManager: NSObject {
    
    var schedule: [Block] {
        get {
            if downloadedSchedule != nil {
                return downloadedSchedule!
            } else {
                let calender = NSCalendar.currentCalendar()
                let weekday = calender.component(.Weekday, fromDate: NSDate())
                return fallbackSchedule[weekday - 2]
            }
        }
    }
    
    var fallbackSchedule: [[Block]]
    var downloadedSchedule: [Block]?
    
    
    override init() {
        let fallbackData: NSData
        if let file = NSBundle.mainBundle().pathForResource("fallbackDatabase", ofType: "json") {
            fallbackData = NSData(contentsOfFile: file)!
        } else {
            fallbackData = NSData()
        }
        fallbackSchedule = [[Block](),[Block](),[Block](),[Block](),[Block]()]
        if let fallbackArray = try? NSJSONSerialization.JSONObjectWithData(fallbackData, options: .AllowFragments) {
            let classArray = ScheduleManager.makeSchedule(fallbackArray as! NSArray)
            for block in classArray {
                let index = block.startTime.weekday - 2
                fallbackSchedule[index].append(block)
            }
        }
        
        
    }
    
    private class func makeSchedule(array: NSArray) -> [Block] {
        var schedule = [Block]()
        for object in array {
            if let dictionary = object as? NSDictionary {
                let block = Block(dictionary: dictionary)
                schedule.append(block)
            }
        }
        return schedule
    }
    
    class func currentClass() {
        
    }
    
    class func nextClass() {
        
    }
    
    class func today() {
        
    }
}
