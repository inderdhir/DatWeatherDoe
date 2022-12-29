//
//  DropdownIconMapper.swift
//  DatWeatherDoe
//
//  Created by Markus Mayer on 2022-11-21.
//  Copyright © 2022 Markus Mayer.
//

import Cocoa

final class DropdownIconMapper {

    func map(_ icon: DropdownIcons) -> NSImage? {
        let symbolName: String

        switch icon {
        case .location:
            symbolName = "mappin"
        case .sun:
            symbolName = "sun.max"
        case .thermometer:
            symbolName = "thermometer.medium"
        case .wind:
            symbolName = "wind"
        }

        let config = NSImage.SymbolConfiguration(textStyle: .title2, scale: .medium)
        return NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)?.withSymbolConfiguration(config)
    }
}
