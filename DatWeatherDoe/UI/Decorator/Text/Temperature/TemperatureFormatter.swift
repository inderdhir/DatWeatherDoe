//
//  TemperatureFormatter.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/12/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol TemperatureFormatterType {
    func getFormattedTemperatureString(
        _ temperature: Double,
        isRoundingOff: Bool
    ) -> String?
}

final class TemperatureFormatter: TemperatureFormatterType {
    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfUp
        return formatter
    }()

    func getFormattedTemperatureString(
        _ temperature: Double,
        isRoundingOff: Bool
    ) -> String? {
        setupTemperatureRounding(isRoundingOff: isRoundingOff)
        return formatTemperatureString(temperature)
    }

    private func setupTemperatureRounding(isRoundingOff: Bool) {
        formatter.maximumFractionDigits = isRoundingOff ? 0 : 1
    }

    private func formatTemperatureString(_ temperature: Double) -> String? {
        let formattedTemperature = formatter.string(from: NSNumber(value: temperature))
        return fixRoundingIssues(formattedTemperature)
    }

    private func fixRoundingIssues(_ temperature: String?) -> String? {
        if temperature == "-0" {
            return "0"
        }
        return temperature
    }
}
