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
            rootView: ConfigureView(
                viewModel: .init(configManager: configManager, popoverManager: self),
                version: version
            )
        )
    }

    private func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }

    private func showPopover() {
        if let statusBarButton {
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: .minY)
        }
    }
}
