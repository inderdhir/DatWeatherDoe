//
//  HumidityTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/15/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation
import OSLog

final class HumidityTextBuilder {
    
    private let initial: String
    private let humidity: Int
    private let logger: Logger
    private let percentString = "\u{0025}"

    private let humidityFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    init(
        initial: String,
        humidity: Int,
        logger: Logger
    ) {
        self.initial = initial
        self.humidity = humidity
        self.logger = logger
    }
    
    func build() -> String {
        guard let humidityString = buildHumidity() else {
            logger.error("Unable to construct humidity string")
            
            return initial
        }
        
        return "\(initial) | \(humidityString)"
    }
    
    private func buildHumidity() -> String? {
        guard let formattedString = buildFormattedString() else { return nil }
        
        return "\(formattedString)\(percentString)"
    }
    
    private func buildFormattedString() -> String? {
        humidityFormatter.string(from: NSNumber(value: humidity))
    }
}
