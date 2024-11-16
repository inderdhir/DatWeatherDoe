//
//  UVIndexTextBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 10/18/24.
//  Copyright © 2024 Inder Dhir. All rights reserved.
//

import Foundation

final class UVIndexTextBuilder {
    private let initial: String
    private let separator: String

    init(initial: String, separator: String) {
        self.initial = initial
        self.separator = separator
    }

    func build(from response: WeatherAPIResponse) -> String {
        "\(initial) \(separator) \(constructUVString(from: response))"
    }

    func constructUVString(from response: WeatherAPIResponse) -> String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentUVIndex = response.getHourlyUVIndex(hour: currentHour)
        return "UV Index: \(currentUVIndex)"
    }
}
