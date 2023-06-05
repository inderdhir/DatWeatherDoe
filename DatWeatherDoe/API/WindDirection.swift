//
//  WindDirection.swift
//  DatWeatherDoe
//
//  Created by Markus Mayer on 2022-11-21.
//  Copyright © 2022 Markus Mayer.
//

import Foundation

class WindDirection {

    enum Direction {
        case north
        case northNorthEast
        case northEast
        case eastNorthEast
        case east
        case eastSouthEast
        case southEast
        case southSouthEast
        case south
        case southSouthWest
        case southWest
        case westSouthWest
        case west
        case westNorthWest
        case northWest
        case northNorthWest
    }

    /*
     * Compass directions:
     *    N     348.75 -  11.25    350 -  <=  11
     *    NNE    11.25 -  33.75     12 -  <=  34
     *    NE     33.75 -  56.25     35 -  <=  56
     *    ENE    56.25 -  78.75     57 -  <=  79
     *    E      78.75 - 101.25     80 -  <= 101
     *    ESE   101.25 - 123.75    102 -  <= 124
     *    SE    123.75 - 146.25    125 -  <= 146
     *    SSE   146.25 - 168.75    147 -  <= 169
     *    S     168.75 - 191.25    170 -  <= 191
     *    SSW   191.25 - 213.75    192 -  <= 214
     *    SW    213.75 - 236.25    215 -  <= 236
     *    WSW   236.25 - 258.75    237 -  <= 259
     *    W     258.75 - 281.25    260 -  <= 281
     *    WNW   281.25 - 303.75    282 -  <= 304
     *    NW    303.75 - 326.25    305 -  <= 326
     *    NNW   326.25 - 348.75    327 -  <= 349
     */
    // swiftlint:disable:next cyclomatic_complexity
    class func getDirection(_ weather: WeatherData) -> Direction {
        switch weather.windData.degrees {
            // "north" (0...11, 350...359) is handled by the default case
        case 12...34:
            return .northNorthEast
        case 35...56:
            return .northEast
        case 57...79:
            return .eastNorthEast
        case 80...101:
            return .east
        case 102...124:
            return .eastSouthEast
        case 125...146:
            return .southEast
        case 147...169:
            return .southSouthEast
        case 170...191:
            return .south
        case 192...214:
            return .southSouthWest
        case 215...236:
            return .southWest
        case 237...259:
            return .westSouthWest
        case 260...281:
            return .west
        case 282...304:
            return .westNorthWest
        case 305...326:
            return .northWest
        case 327...349:
            return .northNorthWest
        default:
            return .north
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    class func getDirectionStr(_ weather: WeatherData) -> String {
        let windDirection: String

        switch getDirection(weather) {
        case .north:
            windDirection = "N"
        case .northNorthEast:
            windDirection = "NNE"
        case .northEast:
            windDirection = "NE"
        case .eastNorthEast:
            windDirection = "ENE"
        case .east:
            windDirection = "E"
        case .eastSouthEast:
            windDirection = "ESE"
        case .southEast:
            windDirection = "SE"
        case .southSouthEast:
            windDirection = "SSE"
        case .south:
            windDirection = "S"
        case .southSouthWest:
            windDirection = "SSW"
        case .southWest:
            windDirection = "SW"
        case .westSouthWest:
            windDirection = "WSW"
        case .west:
            windDirection = "W"
        case .westNorthWest:
            windDirection = "WNW"
        case .northWest:
            windDirection = "NW"
        case .northNorthWest:
            windDirection = "NNW"
        }

        return NSLocalizedString(windDirection, comment: "Wind Direction")
    }
}
