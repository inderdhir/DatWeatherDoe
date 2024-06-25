//
//  LocationValidator.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/13/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

final class LocationValidator: WeatherValidatorType {
    private let latLong: String

    init(latLong: String) {
        self.latLong = latLong
    }

    func validate() throws {
        let coordinates = latLong.split(separator: ",")
        let isValid = coordinates.count == 2
        if !isValid {
            throw WeatherError.latLongIncorrect
        }
    }
}
