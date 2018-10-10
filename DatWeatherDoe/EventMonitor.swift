//
//  EventMonitor.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/22/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Cocoa

class EventMonitor {
    private var monitor: AnyObject?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    public init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(
            matching: mask, handler: handler) as AnyObject?
    }
    
    func stop() {
        if let mon = monitor {
            NSEvent.removeMonitor(mon)
            monitor = nil
        }
    }
}
