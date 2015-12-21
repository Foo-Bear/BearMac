//
//  PreferencesWindowController.swift
//  BearMac
//
//  Created by Jonathan Solomon on 12/19/15.
//  Copyright © 2015 FooBear. All rights reserved.
//

import Cocoa

let kLunchesKey = "lunches"

class PreferencesWindowController: NSWindowController {
    
    var lunches = [1,1,1,1,1]

    @IBOutlet weak var monControl: NSSegmentedControl!
    @IBOutlet weak var tueControl: NSSegmentedControl!
    @IBOutlet weak var wedControl: NSSegmentedControl!
    @IBOutlet weak var thuControl: NSSegmentedControl!
    @IBOutlet weak var friControl: NSSegmentedControl!
    @IBOutlet weak var startOnLoginCheck: NSButton!
    
    var lunchControls: [NSSegmentedControl] {
        get {
            return [monControl, tueControl, wedControl, thuControl, friControl]
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let defaultsLunches = defaults.arrayForKey(kLunchesKey) as? [Int] {
            lunches = defaultsLunches
        }
        
        for var i = 0; i < lunches.count; i++ {
            lunchControls[i].selectedSegment = lunches[i] - 1
        }
        if applicationIsInStartUpItems() {
            startOnLoginCheck.state = 1
        } else {
            startOnLoginCheck.state = 0
        }
        
    }
    
    @IBAction func lunchChanged(sender: NSSegmentedControl) {
        if let index = lunchControls.indexOf(sender) {
            lunches[index] = sender.selectedSegment + 1
            if lunches[index] > 2 {
                lunches[index] = 2
            }
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(lunches, forKey: kLunchesKey)
        }
    }
    
    @IBAction func okPresssed(sender: AnyObject) {
        close()
    }
    
    @IBAction func startOnLoginPressed(sender: NSButton) {
        setLaunchAtStartup(Bool(sender.state))
    }
}
