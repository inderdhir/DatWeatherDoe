//
//  WeatherResponse.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 2/3/18.
//  Copyright © 2018 Inder Dhir. All rights reserved.
//

import Foundation

struct WeatherAPIResponse: Decodable {
    let cityId: Int
    let temperatureData: TemperatureData
    let humidity: Int
    let location: String
    let weatherId: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
    let windData: WindData
    
    struct TemperatureData: Decodable {
        let temperature: Double
        let feelsLikeTemperature: Double
        let minTemperature: Double
        let maxTemperature: Double
        
        private enum CodingKeys: String, CodingKey {
            case temperature = "temp"
            case feelsLikeTemperature = "feels_like"
            case minTemperature = "temp_min"
            case maxTemperature = "temp_max"
        }
    }
    
    struct WindData: Decodable {
        let speed: Double
        let degrees: Int
        
        private enum CodingKeys: String, CodingKey {
            case speed
            case degrees = "deg"
        }

        enum Direction {
            case north
            case north_north_east
            case north_east
            case east_north_east
            case east
            case east_south_east
            case south_east
            case south_south_east
            case south
            case south_south_west
            case south_west
            case west_south_west
            case west
            case west_north_west
            case north_west
            case north_north_west
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
        private func getDirection() -> WindData.Direction {
            switch degrees {
            // "north" (0...11, 350...359) is handled by the default case
            case 12...34:
                return .north_north_east
            case 35...56:
                return .north_east
            case 57...79:
                return .east_north_east
            case 80...101:
                return .east
            case 102...124:
                return .east_south_east
            case 125...146:
                return .south_east
            case 147...169:
                return .south_south_east
            case 170...191:
                return .south
            case 192...214:
                return .south_south_west
            case 215...236:
                return .south_west
            case 237...259:
                return .west_south_west
            case 260...281:
                return .west
            case 282...304:
                return .west_north_west
            case 305...326:
                return .north_west
            case 327...349:
                return .north_north_west
            default:
                return .north
            }
        }

        func getDirectionStr() -> String {
            var ret: String

            switch getDirection() {
            case .north:
                ret = "N"
            case .north_north_east:
                ret = "NNE"
            case .north_east:
                ret = "NE"
            case .east_north_east:
                ret = "ENE"
            case .east:
                ret = "E"
            case .east_south_east:
                ret = "ESE"
            case .south_east:
                ret = "SE"
            case .south_south_east:
                ret = "SSE"
            case .south:
                ret = "S"
            case .south_south_west:
                ret = "SSW"
            case .south_west:
                ret = "SW"
            case .west_south_west:
                ret = "WSW"
            case .west:
                ret = "W"
            case .west_north_west:
                ret = "WNW"
            case .north_west:
                ret = "NW"
            case .north_north_west:
                ret = "NNW"
            }

            return NSLocalizedString(ret, comment: "Wind Direction")
        }
    }
    
    private enum RootKeys: String, CodingKey {
        case cityId = "id"
        case main, weather, humidity, name, sys, wind
    }
    
    private enum APIKeys: String, CodingKey {
        case temperature = "temp"
        case humidity
        case sunrise, sunset
    }
    
    private enum WeatherKeys: String, CodingKey {
        case id
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        
        cityId = try container.decode(Int.self, forKey: .cityId)
        temperatureData = try container.decode(TemperatureData.self, forKey: .main)

        let mainContainer = try container.nestedContainer(keyedBy: APIKeys.self, forKey: .main)
        
        humidity = try mainContainer.decode(Int.self, forKey: .humidity)

        location = try container.decode(String.self, forKey: .name)

        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        let weatherChildContainer = try weatherContainer.nestedContainer(keyedBy: WeatherKeys.self)
        weatherId = try weatherChildContainer.decode(Int.self, forKey: .id)

        let sysContainer = try container.nestedContainer(keyedBy: APIKeys.self, forKey: .sys)
        sunrise = try sysContainer.decode(TimeInterval.self, forKey: .sunrise)
        sunset = try sysContainer.decode(TimeInterval.self, forKey: .sunset)
        
        windData = try container.decode(WindData.self, forKey: .wind)
    }
}
