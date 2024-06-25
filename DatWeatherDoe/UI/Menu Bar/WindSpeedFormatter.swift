//
//  WindSpeedFormatter.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 10/12/23.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

struct WindSpeedInMultipleUnits {
    let meterPerSec: Double
    let milesPerHour: Double
}

protocol WindSpeedFormatterType {
    func getFormattedWindSpeedStringForAllUnits(
        windData: WindData,
        isRoundingOff: Bool
    ) -> String

    func getFormattedWindSpeedString(
        unit: MeasurementUnit,
        windData: WindData
    ) -> String
}

final class WindSpeedFormatter: WindSpeedFormatterType {
    private let degreeString = "\u{00B0}"

    private let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.roundingMode = .halfUp
        return formatter
    }()

    func getFormattedWindSpeedStringForAllUnits(
        windData: WindData,
        isRoundingOff _: Bool
    ) -> String {
        let mphSpeed = windData.speedMph
        let mpsSpeed = mpsSpeedFrom(mphSpeed: mphSpeed)

        let mphRounded = formatter.string(from: NSNumber(value: mphSpeed)) ?? ""
        let windSpeedMph = [mphRounded, "mi/hr"].joined()

        let mpsRounded = formatter.string(from: NSNumber(value: mpsSpeed)) ?? ""
        let windSpeedMps = [mpsRounded, "m/s"].joined()

        let windSpeedStr = [windSpeedMph, windSpeedMps].joined(separator: " | ")

        return combinedWindString(windData: windData, windSpeed: windSpeedStr)
    }

    func getFormattedWindSpeedString(
        unit: MeasurementUnit,
        windData: WindData
    ) -> String {
        let mphSpeed = windData.speedMph
        let mpsSpeed = mpsSpeedFrom(mphSpeed: mphSpeed)

        let speed = unit == .imperial ? mphSpeed : mpsSpeed
        let speedRounded = formatter.string(from: NSNumber(value: speed)) ?? ""
        let windSpeedSuffix = unit == .imperial ? "mi/hr" : "m/s"
        let windSpeedStr = [speedRounded, windSpeedSuffix].joined()

        return combinedWindString(windData: windData, windSpeed: windSpeedStr)
    }

    private func combinedWindString(
        windData: WindData,
        windSpeed: String
    ) -> String {
        let windDegreesStr = [String(windData.degrees), degreeString].joined()
        let windDirectionStr = "(\(windData.direction))"
        let windAndDegreesStr = [windSpeed, windDegreesStr].joined(separator: " - ")
        let windFullStr = [windAndDegreesStr, windDirectionStr].joined(separator: " ")
        return windFullStr
    }

    private func mpsSpeedFrom(mphSpeed: Double) -> Double {
        0.4469 * mphSpeed
    }
}
