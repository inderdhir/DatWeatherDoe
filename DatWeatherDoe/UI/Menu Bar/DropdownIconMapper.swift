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
        let imageString: String

        switch icon {
        case .location:
            imageString = "Location"
        case .sun:
            // Re-uses the forecast icon "sunny"
            imageString = "Sunny"
        case .thermometer:
            imageString = "Thermometer"
        case .wind:
            imageString = "Wind"
        }

        return NSImage(named: imageString)
    }
}
