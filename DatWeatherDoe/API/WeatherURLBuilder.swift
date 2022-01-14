//
//  WeatherURLBuilder.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation
import Foundation

final class WeatherURLBuilder {
    
    private let apiUrlString = "https://api.openweathermap.org/data/2.5/weather"
    private let appId: String
    
    init(appId: String) {
        self.appId = appId
    }

    func buildUrl(zipCode: String) -> URL? {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "zip", value: zipCode)
        ]
        
        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }
    
    func buildUrl(location: CLLocationCoordinate2D) -> URL? {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId),
            URLQueryItem(name: "lat", value: String(describing: location.latitude)),
            URLQueryItem(name: "lon", value: String(describing: location.longitude)),
        ]
        
        var urlComps = URLComponents(string: apiUrlString)
        urlComps?.queryItems = queryItems
        return urlComps?.url
    }
}
