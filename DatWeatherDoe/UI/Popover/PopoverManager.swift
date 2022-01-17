//
//  PopoverManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa

final class PopoverManager {
    
    private let statusBarButton: NSStatusBarButton?
    private let popover = NSPopover()
    private var eventMonitor: EventMonitor?
    private let refreshCallback: () -> Void

    init(
        statusBarButton: NSStatusBarButton?,
        configManager: ConfigManagerType,
        refreshCallback: @escaping () -> Void
    ) {
        self.statusBarButton = statusBarButton
        self.refreshCallback = refreshCallback
        
        setupConfigurationView(configManager)
        setupEventMonitor()
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
            refreshCallback()
        } else {
            showPopover(sender)
        }
    }
    
    private func setupConfigurationView(_ configManager: ConfigManagerType) {
        popover.contentViewController = ConfigureViewController(
            configManager: configManager,
            popoverManager: self
        )
    }
    
    private func setupEventMonitor() {
        eventMonitor = createEventMonitor()
        eventMonitor?.start()
    }
    
    private func createEventMonitor() -> EventMonitor {
        EventMonitor(mask: .leftMouseDown) { [weak self] event in
            self?.closePopoverwhenClickedOutside(event: event)
        }
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    private func showPopover(_ sender: AnyObject?) {
        if let button = statusBarButton {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
        
        eventMonitor?.start()
    }
    
    private func closePopoverwhenClickedOutside(event: NSEvent?) {
        DispatchQueue.main.async { [weak self] in
            if self?.popover.isShown == true {
                self?.closePopover(event)
            }
        }
    }
}
