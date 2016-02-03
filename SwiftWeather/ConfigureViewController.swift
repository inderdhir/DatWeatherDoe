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
    
    let FAHRENHEIT_STRING: String = "\u{00B0}F"
    let CELSIUS_STRING: String = "\u{00B0}C"
    
    @IBOutlet weak var zipCodeField: NSTextField!
    @IBOutlet weak var refreshIntervals: NSPopUpButton!
    
    @IBOutlet weak var useLocationToggleCheckBox: NSButton!
    @IBOutlet weak var fahrenheitRadioButton: NSButton!
    @IBOutlet weak var celsiusRadioButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipCodeField.placeholderString = "10021"
        refreshIntervals.removeAllItems()
        refreshIntervals.addItemsWithTitles(intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])
        
        // Radio buttons
        fahrenheitRadioButton.title = FAHRENHEIT_STRING
        celsiusRadioButton.title = CELSIUS_STRING
        
        // Defaults
        let savedUnit = DefaultsChecker.getDefaultUnit()
        if savedUnit == TemperatureUnits.F_UNIT.rawValue {
            fahrenheitRadioButton.state = NSOnState
        }
        else {
            celsiusRadioButton.state = NSOnState
        }
        if DefaultsChecker.getDefaultLocationUsedToggle() == true {
            useLocationToggleCheckBox.state = NSOnState
            locationEnabledUpdate(true)
        }
        else {
            useLocationToggleCheckBox.state = NSOffState
            locationEnabledUpdate(false)
        }
    }
    
    
    func locationEnabledUpdate(enabled: Bool) {
        zipCodeField.enabled = !enabled
    }
    
    @IBAction func radioButtonClicked(sender: NSButton) {
        if sender.title == FAHRENHEIT_STRING {
            if fahrenheitRadioButton.state == NSOffState {
                sender.state = NSOnState
                celsiusRadioButton.state = NSOffState
            }
        }
        else {
            if celsiusRadioButton.state == NSOffState {
                sender.state = NSOnState
                fahrenheitRadioButton.state = NSOffState
            }
        }
    }
    
    @IBAction func uselocationCheckboxClicked(sender: NSButton) {
        if sender.state == NSOnState {
            locationEnabledUpdate(true)
        }
        else {
            locationEnabledUpdate(false)
        }
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        var zipCode: String? = nil
        var refreshInterval: Double? = nil
        var unit: String? = nil
        
        switch refreshIntervals.indexOfSelectedItem {
        case 1:
            refreshInterval = 300
            break
        case 2  :
            refreshInterval = 900
            break
        case 3:
            refreshInterval = 1800
            break
        case 4:
            refreshInterval = 3600
            break
        default:
            refreshInterval = 60
            break
        }
        
        // Save all preferences
        if(zipCodeField.stringValue.characters.count > 0){
            zipCode = zipCodeField.stringValue + ",us"
        }
        else{
            zipCode = "10021,us"
        }
        if fahrenheitRadioButton.state == NSOnState {
            unit = TemperatureUnits.F_UNIT.rawValue
        }
        else {
            unit = TemperatureUnits.C_UNIT.rawValue
        }
        
        
        appDelegate.zipCode = zipCode!
        appDelegate.refreshInterval = NSTimeInterval(refreshInterval!)
        appDelegate.unit = unit
        appDelegate.getWeatherViaZipCode()
        
        DefaultsChecker.setDefaultZipCode(zipCode!)
        DefaultsChecker.setDefaultRefreshInterval(String(refreshInterval!))
        DefaultsChecker.setDefaultUnit(unit!)
        if useLocationToggleCheckBox.state == NSOnState {
            DefaultsChecker.setDefaultLocationUsedToggle(true)
        }
        else {
            DefaultsChecker.setDefaultLocationUsedToggle(false)
        }
        
        self.view.window?.close()
    }
}
