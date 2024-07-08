//
//  WeatherURLBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

protocol WeatherURLBuilderType {
    func build() throws -> URL
}

final class WeatherURLBuilder: WeatherURLBuilderType {
    private let apiUrlString = "https://api.weatherapi.com/v1/forecast.json"
    private let appId: String
    private let location: CLLocationCoordinate2D

    init(appId: String, location: CLLocationCoordinate2D) {
        self.appId = appId
        self.location = location
    }

    func build() throws -> URL {
        let latLonString = "\(location.latitude),\(location.longitude)"

        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "key", value: appId),
            URLQueryItem(name: "aqi", value: String("yes")),
            URLQueryItem(name: "q", value: latLonString),
            URLQueryItem(name: "dt", value: parsedDateToday)
        ]

        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems

        guard let finalUrl = urlComps?.url else {
            throw WeatherError.unableToConstructUrl
        }
        return finalUrl
    }

    private var parsedDateToday: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
}
