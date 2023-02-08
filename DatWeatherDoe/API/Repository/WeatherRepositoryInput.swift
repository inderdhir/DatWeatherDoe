//
//  WeatherRepositoryInput.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/16/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

enum WeatherRepositoryInput {
    case location(coordinates: CLLocationCoordinate2D)
    case latLong(latLong: String)
    case city(city: String)
}
