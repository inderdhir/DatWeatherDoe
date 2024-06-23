//
//  SunriseAndSunsetTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Markus Markus on 2022-07-26.
//  Copyright © 2022 Markus Mayer.
//

import Foundation

protocol SunriseAndSunsetTextBuilderType {
    func build() -> String
}

final class SunriseAndSunsetTextBuilder: SunriseAndSunsetTextBuilderType {
    private let sunset: String
    private let sunrise: String

    private let upArrowStr = "⬆"
    private let downArrowStr = "⬇"

    init(sunset: String, sunrise: String) {
        self.sunset = sunset
        self.sunrise = sunrise
    }

    func build() -> String {
        "\(upArrowStr)\(sunrise) \(downArrowStr)\(sunset)"
    }
}
