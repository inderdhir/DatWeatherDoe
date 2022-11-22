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

    class func getDirectionStr(_ weather: WeatherData) -> String {
        var ret: String

        switch getDirection(weather) {
        case .north:
            ret = "N"
        case .northNorthEast:
            ret = "NNE"
        case .northEast:
            ret = "NE"
        case .eastNorthEast:
            ret = "ENE"
        case .east:
            ret = "E"
        case .eastSouthEast:
            ret = "ESE"
        case .southEast:
            ret = "SE"
        case .southSouthEast:
            ret = "SSE"
        case .south:
            ret = "S"
        case .southSouthWest:
            ret = "SSW"
        case .southWest:
            ret = "SW"
        case .westSouthWest:
            ret = "WSW"
        case .west:
            ret = "W"
        case .westNorthWest:
            ret = "WNW"
        case .northWest:
            ret = "NW"
        case .northNorthWest:
            ret = "NNW"
        }

        return NSLocalizedString(ret, comment: "Wind Direction")
    }
}
