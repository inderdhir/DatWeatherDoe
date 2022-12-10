//
//  LocationWeatherURLBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/16/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

final class LocationWeatherURLBuilder: WeatherURLBuilder {
    
    private let location: CLLocationCoordinate2D
    
    init(appId: String, location: CLLocationCoordinate2D) {
        self.location = location
        super.init(appId: appId)
    }
    
    override func build() throws -> URL {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "lat", value: String(describing: location.latitude)),
            URLQueryItem(name: "lon", value: String(describing: location.longitude)),
        ]
        
        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        guard let finalUrl = urlComps?.url else {
            throw WeatherError.unableToConstructUrl
        }
        return finalUrl
    }
}
