//
//  DropdownIconMapper.swift
//  DatWeatherDoe
//
//  Created by Markus Mayer on 2022-11-21.
//  Copyright © 2022 Markus Mayer.
//

import Cocoa

protocol DropdownIconMapperType {
    func map(_ icon: DropdownIcon) -> NSImage?
}

final class DropdownIconMapper: DropdownIconMapperType {
    func map(_ icon: DropdownIcon) -> NSImage? {
        let symbolName: String
        let accessibilityDescription: String

        switch icon {
        case .location:
            symbolName = "location.north.circle"
            accessibilityDescription = "Location"
        case .thermometer:
            symbolName = "thermometer.snowflake.circle"
            accessibilityDescription = "Temperature"
        case .sun:
            symbolName = "sun.horizon.circle"
            accessibilityDescription = "Sunrise and Sunset"
        case .wind:
            symbolName = "wind.circle"
            accessibilityDescription = "Wind data"
        }

        let config = NSImage.SymbolConfiguration(textStyle: .title2, scale: .medium)
        return NSImage(
            systemSymbolName: symbolName,
            accessibilityDescription: accessibilityDescription
        )?.withSymbolConfiguration(config)
    }
}
