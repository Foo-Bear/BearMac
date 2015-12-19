//
//  ScheduleManager.swift
//  BearMac
//
//  Created by Jonathan Solomon on 12/17/15.
//  Copyright © 2015 FooBear. All rights reserved.
//

import Cocoa

class ScheduleManager: NSObject {
    
    var todaySchedule: [Block] {
        get {
            if downloadedSchedule != nil {
                return downloadedSchedule!
            } else {
                let calendar = NSCalendar.currentCalendar()
                let weekday = calendar.component(.Weekday, fromDate: NSDate())
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
    
    func currentClass() -> Block? {
        let calendar = NSCalendar.currentCalendar()
        let now = calendar.components([.Hour, .Minute], fromDate: NSDate())
        for block in todaySchedule {
            if block.startTime.hour < now.hour &&
                block.startTime.minute < now.minute &&
                block.endTime.hour > now.hour &&
                block.endTime.minute > now.minute {
                    return block
            }
        }
        return nil
    }
    
    func nextClass() -> Block? {
        let calendar = NSCalendar.currentCalendar()
        let now = calendar.components([.Hour, .Minute], fromDate: NSDate())
        for block in todaySchedule {
            if block.startTime.hour > now.hour &&
                block.startTime.minute > now.minute {
                    return block
            }
        }
        return nil
    }
    
    func timeLeftInCurrentClass() -> Int { //in minutes
        if let currentClass = currentClass() {
            let calendar = NSCalendar.currentCalendar()
            let now = calendar.components([.Hour, .Minute], fromDate: NSDate())
            let hoursLeft = currentClass.endTime.hour - now.hour
            let minutesLeft = currentClass.endTime.minute - now.minute
            let timeLeft = hoursLeft * 60 + minutesLeft
            return timeLeft
        } else {
            return 0
        }
    }
    
    func timeUntilNextClass() -> Int { //in minutes
        if let nextClass = nextClass() {
            let calendar = NSCalendar.currentCalendar()
            let now = calendar.components([.Hour, .Minute], fromDate: NSDate())
            let hoursLeft = now.hour - nextClass.startTime.hour
            let minutesLeft = now.minute - nextClass.startTime.minute
            let timeLeft = hoursLeft * 60 + minutesLeft
            return timeLeft
        } else {
            return 0
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
    
}
