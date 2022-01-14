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
        
        popover.contentViewController = ConfigureViewController(
            configManager: configManager,
            popoverManager: self
        )
        
        eventMonitor = createEventMonitor()
        eventMonitor?.start()
    }
    
    func togglePopover(_ sender: AnyObject) {
        if popover.isShown {
            closePopover(sender)
            refreshCallback()
        } else {
            showPopover(sender)
        }
    }
    
    private func createEventMonitor() -> EventMonitor {
        EventMonitor(mask: .leftMouseDown) { [weak self] event in
            self?.closePopoverwhenClickedOutside(event: event)
        }
    }
    
    private func closePopover(_ sender: AnyObject?) {
        closePopoverWindow(sender)
        eventMonitor?.stop()
    }
    
    private func showPopover(_ sender: AnyObject?) {
        showPopoverWindow()
        eventMonitor?.start()
    }
    
    private func closePopoverwhenClickedOutside(event: NSEvent?) {
        DispatchQueue.main.async { [weak self] in
            if self?.popover.isShown == true {
                self?.closePopover(event)
            }
        }
    }
    
    private func closePopoverWindow(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    private func showPopoverWindow() {
        if let button = statusBarButton {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
