//
//  APIKeyParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/11/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class APIKeyParser {
    func parse() -> String {
        guard let apiKey = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String else {
            fatalError("Unable to find OPENWEATHERMAP_APP_ID in `Config.xcconfig`")
        }
        return apiKey
    }
}
