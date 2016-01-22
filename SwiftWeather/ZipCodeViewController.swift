//
//  ZipCodeViewController.swift
//  SwiftWeather
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class ZipCodeViewController: NSViewController {

    @IBOutlet weak var zipCodeField: NSTextField!
    var zipCode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        zipCode = zipCodeField.stringValue
    }
}
