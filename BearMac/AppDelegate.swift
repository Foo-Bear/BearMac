//
//  AppDelegate.swift
//  BearMac
//
//  Created by Jonathan Solomon on 12/17/15.
//  Copyright © 2015 FooBear. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    let scheduleManager = ScheduleManager()
    var timer: NSTimer!
    var timeLeft = 0
    
    //Menu
    let menu = NSMenu()
    let nowItem = NSMenuItem(title: "Now: Block 1", action: nil, keyEquivalent: "")
    let nextItem = NSMenuItem(title: "Next: Block 2", action: nil, keyEquivalent: "")


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as! String
        menu.addItem(nowItem)
        nowItem.enabled = false
        menu.addItem(nextItem)
        nowItem.enabled = false
        menu.addItem(NSMenuItem.separatorItem())
        menu.addItem(NSMenuItem(title: "Quit \(appName)", action: Selector("terminate:"), keyEquivalent: ""))
        statusItem.menu = menu
        updateSchedule()
        //This works better than before, but might be a resource hog
        timer = NSTimer(timeInterval: 1, target: self, selector: Selector("updateSchedule"), userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
    }
    
    func updateSchedule() {
        statusItem.title = "No School!"
        nowItem.hidden = true
        nextItem.hidden = true
        if let nextClass = scheduleManager.nextClass() {
            nextItem.title = "Next: \(nextClass.name)"
            nextItem.hidden = false
            menu.itemChanged(nextItem)
            timeLeft = scheduleManager.timeUntilNextClass()
            updateStatusBar()
        }
        if let currentClass = scheduleManager.currentClass() {
            nowItem.title = "Now: \(currentClass.name)"
            nowItem.hidden = false
            menu.itemChanged(nowItem)
            timeLeft = scheduleManager.timeLeftInCurrentClass()
            updateStatusBar()
        }
    }
    
    func updateStatusBar() {
        let timeLeftHours = timeLeft / 60
        let timeLeftMinutes = timeLeft % 60
        if timeLeftMinutes == 0 {
            statusItem.title = "\(timeLeftHours):00"
        } else if timeLeftMinutes < 10 {
            statusItem.title = "\(timeLeftHours):0\(timeLeftMinutes)"
        } else {
            statusItem.title = "\(timeLeftHours):\(timeLeftMinutes)"
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

