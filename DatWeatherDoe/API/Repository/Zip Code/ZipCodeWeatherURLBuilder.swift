//
//  ZipCodeWeatherURLBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/16/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class ZipCodeWeatherURLBuilder: WeatherURLBuilder {
    private let zipCode: String

    init(appId: String, zipCode: String) {
        self.zipCode = zipCode
        super.init(appId: appId)
    }

    override func build() throws -> URL {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "zip", value: zipCode),
        ]

        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        guard let finalUrl = urlComps?.url else {
            throw WeatherError.unableToConstructUrl
        }
        return finalUrl
    }
}
