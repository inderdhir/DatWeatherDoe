//
//  SunriseAndSunsetTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Markus Markus on 2022-07-26.
//  Copyright © 2022 Markus Mayer.
//

import Foundation

final class SunriseAndSunsetTextBuilder {

    private let sunset: TimeInterval
    private let sunrise: TimeInterval

    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"

    init(
        sunset: TimeInterval,
        sunrise: TimeInterval
    ) {
        self.sunset = sunset
        self.sunrise = sunrise
    }

    func build() -> String {
        buildRiseSet()
    }

    private func buildRiseSet() -> String {
        let sunRiseText = buildFormattedString(timestamp: sunrise)
        let sunSetText = buildFormattedString(timestamp: sunset)
        let sunriseAndSunsetString = "\(upArrowStr)\(sunRiseText) \(downArrowStr)\(sunSetText)"
        return sunriseAndSunsetString
    }

    private func buildFormattedString(timestamp: TimeInterval) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}
