//
//  PopoverManager.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Cocoa
import SwiftUI

final class PopoverManager {
    private var eventMonitor: EventMonitor?
    private var configureViewModel: ConfigureViewModel!
    private let popover = NSPopover()
    private let refreshCallback: () -> Void
    private weak var statusBarButton: NSStatusBarButton?

    init(
        statusBarButton: NSStatusBarButton?,
        configManager: ConfigManagerType,
        refreshCallback: @escaping () -> Void
    ) {
        self.statusBarButton = statusBarButton
        self.refreshCallback = refreshCallback

        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)
        configureViewModel = ConfigureViewModel(configManager: configManager, popoverManager: self)
        
        setupConfigurationView(configManager)
    }

    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
            refreshCallback()
        } else {
            showPopover()
        }
    }

    private func setupConfigurationView(_ configManager: ConfigManagerType) {
        popover.contentSize = NSSize(width: 360, height: 360)
        
        let version = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
        popover.contentViewController = NSHostingController(
            rootView: ConfigureView(viewModel: configureViewModel, version: version)
        )
    }

    private func showPopover() {
        if let statusBarButton {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
            eventMonitor?.start()
        }
    }
    
    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    private func mouseEventHandler(_ event: NSEvent?) {
        if popover.isShown {
            closePopover(nil)
        }
        configureViewModel.saveConfig()
        refreshCallback()
    }
}
