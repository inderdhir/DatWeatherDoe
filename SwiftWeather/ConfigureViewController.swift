//
//  ConfigureViewController.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController {
    
    let intervalStrings: [String] = ["1 min", "5 min", "15 min", "30 min", "60 min"]
    
    @IBOutlet weak var zipCodeField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipCodeField.placeholderString = "10021"
        refreshIntervals.removeAllItems()
        refreshIntervals.addItemsWithTitles(intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        var refreshInterval: NSTimeInterval? = nil
        
        switch refreshIntervals.indexOfSelectedItem {
        case 1:
            refreshInterval = NSTimeInterval(300)
            break
        case 2:
            refreshInterval = NSTimeInterval(900)
            break
        case 3:
            refreshInterval = NSTimeInterval(1800)
            break
        case 4:
            refreshInterval = NSTimeInterval(3600)
            break
        default:
            refreshInterval = NSTimeInterval(60)
            break
        }
        
        appDelegate.refreshInterval = refreshInterval!
        if(zipCodeField.stringValue.characters.count > 0){
            appDelegate.zipCode = zipCodeField.stringValue + ",us"
        }
        else{
            appDelegate.zipCode = "10021,us"
        }
        appDelegate.getWeather()
        100
        self.view.window?.close()
    }
}
