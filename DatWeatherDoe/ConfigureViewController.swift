//
//  ConfigureViewController.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ConfigureViewController: NSViewController, NSTextFieldDelegate {
    
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
        
        refreshIntervals.removeAllItems()
        refreshIntervals.addItems(withTitles: intervalStrings)
        refreshIntervals.setTitle(intervalStrings[0])
        
        zipCodeField.delegate = self

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
            zipCodeField.isEnabled = false
        }
        else {
            useLocationToggleCheckBox.state = NSOffState
            zipCodeField.isEnabled = true
        }
        zipCodeField.placeholderString = DefaultsChecker.getDefaultZipCode()
        
        let refreshInterval = Int(DefaultsChecker.getDefaultRefreshInterval())
        switch refreshInterval {
        case 300:
            refreshIntervals.selectItem(at: 1)
            break
        case 900:
            refreshIntervals.selectItem(at: 2)
            break
        case 1800:
            refreshIntervals.selectItem(at: 3)
            break
        case 3600:
            refreshIntervals.selectItem(at: 4)
            break
        default:
            refreshIntervals.selectItem(at: 0)
            break
        }
    }
    
    @IBAction func radioButtonClicked(_ sender: NSButton) {
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
    
    @IBAction func uselocationCheckboxClicked(_ sender: NSButton) {
        if sender.state == NSOnState {
            zipCodeField.isEnabled = false
        }
        else {
            zipCodeField.isEnabled = true
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
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
            zipCode = zipCodeField.stringValue
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
        appDelegate.refreshInterval = TimeInterval(refreshInterval!)
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
