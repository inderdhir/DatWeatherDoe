//
//  RiseSetTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Markus Markus on 7/26/22.
//  Copyright © 2022 Markus Mayer.
//

import Foundation

final class RiseSetTextBuilder {

    private let initial: String
    private let sunset: TimeInterval
    private let sunrise: TimeInterval

    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"

    init(
        initial: String = "",
        sunset: TimeInterval = 0,
        sunrise: TimeInterval = 0
    ) {
        self.initial = initial
        self.sunset = sunset
        self.sunrise = sunrise
    }

    func build() -> String {
        let riseSetString = buildRiseSet()
        if riseSetString == "" {
            return initial
        }
        return (initial != "") ? "\(initial) \(riseSetString)" : riseSetString
    }

    private func buildRiseSet() -> String {
        var ret: String = ""
        let sunRiseText = buildFormattedString(ts: sunrise)
        let sunSetText = buildFormattedString(ts: sunset)

        if sunRiseText != "" {
            ret = "\(upArrowStr)\(sunRiseText)"
        }
        if sunSetText != "" {
            if ret != "" {
                ret += " "
            }
            ret += "\(downArrowStr)\(sunSetText)"
        }

        return ret
    }

    private func buildFormattedString(ts: TimeInterval) -> String {
        if ts == 0 {
            return ""
        }
        return getDateFormatter().string(from: Date(timeIntervalSince1970: ts))
    }

    private func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
