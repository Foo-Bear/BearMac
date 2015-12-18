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


    func applicationDidFinishLaunching(aNotification: NSNotification) {
        statusItem.title = "34:56"
        print(scheduleManager.schedule)
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

