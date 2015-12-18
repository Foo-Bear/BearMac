//
//  DataObjects.swift
//  BearMac
//
//  Created by Jonathan Solomon on 12/17/15.
//  Copyright © 2015 FooBear. All rights reserved.
//

import Cocoa

struct Block {
    
    var keyName = ""
    var name = ""
    var startTime = NSDateComponents()
    var endTime = NSDateComponents()
    
    init() { }
    
    init(dictionary: NSDictionary) {
        keyName = dictionary["key_name"] as! String
        name = dictionary["name"] as! String
        
        let sHour = dictionary["shour"] as! Int
        let sMin = dictionary["smin"] as! Int
        let eHour = dictionary["ehour"] as! Int
        let eMin = dictionary["emin"] as! Int
        let day = dictionary["day"] as! Int
        
        startTime.hour = sHour
        startTime.minute = sMin
        startTime.weekday = day + 1
        endTime.hour = eHour
        endTime.minute = eMin
        endTime.weekday = day + 1
        
    }
}