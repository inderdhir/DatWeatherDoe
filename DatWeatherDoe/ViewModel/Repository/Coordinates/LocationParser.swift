//
//  LocationParser.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/10/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import CoreLocation

protocol LocationParserType {
    func parseCoordinates(_ latLong: String) throws -> CLLocationCoordinate2D
}

final class LocationParser: LocationParserType {
    func parseCoordinates(_ latLong: String) throws -> CLLocationCoordinate2D {
        let latLongCombo = latLong.split(separator: ",")
        guard latLongCombo.count == 2 else {
            throw WeatherError.latLongIncorrect
        }

        return try parseLocationDegrees(
            possibleLatitude: String(latLongCombo[0]).trim(),
            possibleLongitude: String(latLongCombo[1]).trim()
        )
    }

    private func parseLocationDegrees(
        possibleLatitude: String,
        possibleLongitude: String
    ) throws -> CLLocationCoordinate2D {
        let lat = CLLocationDegrees(possibleLatitude.trim())
        let long = CLLocationDegrees(possibleLongitude.trim())
        guard let lat, let long else {
            throw WeatherError.latLongIncorrect
        }

        return .init(latitude: lat, longitude: long)
    }
}

private extension String {
    func trim() -> String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
