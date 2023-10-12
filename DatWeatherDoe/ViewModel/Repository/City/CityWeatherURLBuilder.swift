//
//  CityWeatherURLBuilder.swift
//  DatWeatherDoe
//
//  Created by preckrasno on 14.02.2023.
//  Copyright © 2023 Inder Dhir. All rights reserved.
//

import Foundation

final class CityWeatherURLBuilder: WeatherURLBuilder {
    
    private let city: String
    
    init(appId: String, city: String) {
        self.city = city
        super.init(appId: appId)
    }
    
    override func build() throws -> URL {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "q", value: city)
        ]
        
        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        guard let finalUrl = urlComps?.url else {
            throw WeatherError.unableToConstructUrl
        }
        return finalUrl
    }
}
