//
//  ScheduleManager.swift
//  BearMac
//
//  Created by Jonathan Solomon on 12/17/15.
//  Copyright © 2015 FooBear. All rights reserved.
//

import Cocoa

let baseURL = NSURL(string: "http://localhost:3000/")

class ScheduleManager: NSObject {
    
    var todaySchedule: [Block] {
        get {
            if downloadedSchedule != nil {
                return downloadedSchedule!
            } else {
                let calendar = NSCalendar.currentCalendar()
                let weekday = calendar.component(.Weekday, fromDate: NSDate())
                if weekday == 1 || weekday == 7 {
                    return [Block]()
                } else {
                    return fallbackSchedule[weekday - 2]
                }
            }
        }
    }
    
    var lunches: [Int] {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let lunches = defaults.arrayForKey(kLunchesKey) as? [Int]{
                return lunches
            } else {
                return [1,1,1,1,1]
            }
        }
    }
    
    var fallbackSchedule: [[Block]]
    var downloadedSchedule: [Block]?
    
    //downloads
    var downloadCompletionHandler: ((NSData?, NSURLResponse?, NSError?)->Void)!
    let downloadRequest = NSMutableURLRequest(URL: NSURL(string: "today", relativeToURL: baseURL)!, cachePolicy: .ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
    
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
        super.init()
        downloadCompletionHandler = { (let data, let response, let error) in
            let timer: NSTimer
            if error != nil && data != nil {
                if let todayArray = try? NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) {
                    self.downloadedSchedule = ScheduleManager.makeSchedule(todayArray as! NSArray)
                    timer = NSTimer(timeInterval: 216000, target: self, selector: "redownloadSchedule", userInfo: nil, repeats: false)
                    NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
                }
            } else if let error = error {
                print(error.localizedDescription)
                timer = NSTimer(timeInterval: 180, target: self, selector: "redownloadSchedule", userInfo: nil, repeats: false)
                NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            }
        }
        self.redownloadSchedule()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "redownloadSchedule", name: NSSystemClockDidChangeNotification, object: nil)
    }
    
    func redownloadSchedule() {
        let session = NSURLSession.sharedSession()
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(downloadRequest, completionHandler: downloadCompletionHandler)
        task.resume()
    }
    
    func currentClass() -> Block? {
        let calendar = NSCalendar.currentCalendar()
        let now = calendar.components([.Hour, .Minute], fromDate: NSDate())
        let nowMinutes = now.hour * 60 + now.minute
        for block in todaySchedule {
            let blockStartMinutes = block.startTime.hour * 60 + block.startTime.minute
            let blockEndMinutes = block.endTime.hour * 60 + block.endTime.minute
            if blockStartMinutes <= nowMinutes &&
                blockEndMinutes > nowMinutes {
                    let lunchID = Int(String(block.keyName[block.keyName.endIndex.predecessor()]))!
                    let calendar = NSCalendar.currentCalendar()
                    let weekday = calendar.component(.Weekday, fromDate: NSDate())
                    let lunch = lunches[weekday - 2]
                    if lunchID == 0 || lunchID == lunch {
                        return block
                    }
            }
        }
        return nil
    }
    
    func nextClass() -> Block? {
        let calendar = NSCalendar.currentCalendar()
        let now = calendar.components([.Hour, .Minute], fromDate: NSDate())
        let nowMinutes = now.hour * 60 + now.minute
        for block in todaySchedule {
            let blockStartMinutes = block.startTime.hour * 60 + block.startTime.minute
            if blockStartMinutes > nowMinutes {
                let lunchID = Int(String(block.keyName[block.keyName.endIndex.predecessor()]))!
                let calendar = NSCalendar.currentCalendar()
                let weekday = calendar.component(.Weekday, fromDate: NSDate())
                let lunch = lunches[weekday - 2]
                if lunchID == 0 || lunchID == lunch {
                    return block
                }
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
            let hoursLeft = nextClass.startTime.hour - now.hour
            let minutesLeft = nextClass.startTime.minute - now.minute
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
