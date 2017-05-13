//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import Foundation
import SwiftHTTP
import CoreLocation

class WeatherService {

    let cmcStations = "cmc stations"
    let apiUrl = "http://api.openweathermap.org/data/2.5/weather"
    let openWeatherMapAppId = "OPENWEATHERMAP_APP_ID"
    let formatter = NumberFormatter()
    let zipString = "zip"
    let appIdString = "appid"
    let latitudeString = "lat"
    let longitudeString = "lon"

    var appId: String?
    var darkModeOn: Bool = false

    init() {
        // Get App ID
        if let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist") {
            let plist = NSDictionary(contentsOfFile:filePath)
            appId = plist![openWeatherMapAppId] as? String
        }

        // Weather string formatter
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        darkModeOn = false
    }

    // Zipcode-based weather
    func getWeather(_ zipCode: String, unit: String,
                    completion: @escaping (_ currentTempString: String, _ iconString: String) -> Void) {
        do {
            try HTTP.GET(apiUrl, parameters: [zipString: zipCode, appIdString: appId!])
                .start { [unowned self] response in
                if let err = response.error {
                    #if DEBUG
                        print("error: \(err.localizedDescription)")
                    #endif
                    return //also notify app of failure as needed
                }
                self.parseResponse(response, unit: unit, completion: completion)

                #if DEBUG
                    print("opt finished: \(response.description)")
                #endif

            }
        } catch let error {
            #if DEBUG
                print("got an error creating the request: \(error)")
            #endif
        }
    }

    // Location-based weather
    func getWeather(_ location: CLLocationCoordinate2D, unit: String,
                    completion: @escaping (_ currentTempString: String,
                    _ iconString: String) -> Void) {
        let latitude: String = "\(location.latitude)"
        let longitude: String = "\(location.longitude)"

        do {
            try HTTP.GET(apiUrl, parameters: [latitudeString: latitude,
                                              longitudeString: longitude, appIdString: appId!])
                .start { [unowned self] response in
                if let err = response.error {
                    #if DEBUG
                        print("error: \(err.localizedDescription)")
                    #endif
                    return //also notify app of failure as needed
                }

                self.parseResponse(response, unit: unit, completion: completion)

                #if DEBUG
                    print("opt finished: \(response.description)")
                #endif
            }
        } catch let error {
            #if DEBUG
                print("got an error creating the request: \(error)")
            #endif
        }
    }

    // Response
    func parseResponse(_ resp: Response, unit: String, completion:
        (_ currentTempString: String, _ iconString: String) -> Void)
    {
        // Temperature
        var currentTempString: String? = nil

        do {
            let response: Any? = try JSONSerialization.jsonObject(
                with: resp.data, options: JSONSerialization.ReadingOptions())

            if let dict = response as? NSDictionary, let mainDict = dict["main"] as? NSDictionary,
                let temp = mainDict["temp"], let weatherDict =
                ((dict["weather"] as? NSArray)?[0] as? NSDictionary) {

                guard let doubleTemp = (temp as? NSNumber)?.doubleValue else { return }

                var temperature: Double? = nil

                if unit == TemperatureUnits.fahrenheit.rawValue {
                    temperature = ((doubleTemp - 273.15) * 1.8) + 32
                } else {
                    temperature = doubleTemp - 273.15
                }
                currentTempString = formatter.string(from: NSNumber(value: temperature!))! + "\u{00B0}"

                // Icon
                var iconString: String? = nil
                guard let weatherID = weatherDict["id"], let weatherIDInt = weatherID as? Int else { return }
                
                if weatherIDInt >= 800 && weatherIDInt <= 900 {
                    switch(weatherIDInt) {
                    case 800:
                        iconString = darkModeOn ?
                            WeatherConditions.sunnyDark.rawValue : WeatherConditions.sunny.rawValue
                        break
                    case 801:
                        iconString = darkModeOn ?
                            WeatherConditions.partlyCloudyDark.rawValue :
                            WeatherConditions.partlyCloudy.rawValue
                        break
                    default:
                        iconString = darkModeOn ?
                            WeatherConditions.cloudyDark.rawValue : WeatherConditions.cloudy.rawValue
                        break
                    }
                } else if weatherIDInt >= 700 {
                    iconString = darkModeOn ?
                        WeatherConditions.mistDark.rawValue : WeatherConditions.mist.rawValue
                } else if weatherIDInt >= 600 {
                    iconString = darkModeOn ?
                        WeatherConditions.snowDark.rawValue : WeatherConditions.snow.rawValue
                } else if weatherIDInt >= 500 {
                    if weatherIDInt == 511 {
                        iconString = darkModeOn ?
                            WeatherConditions.freezingRainDark.rawValue :
                            WeatherConditions.freezingRain.rawValue
                    } else if weatherIDInt <= 504 {
                        iconString = darkModeOn ?
                            WeatherConditions.heavyRainDark.rawValue :
                            WeatherConditions.heavyRain.rawValue
                    } else if weatherIDInt >= 520 {
                        iconString = darkModeOn ?
                            WeatherConditions.partlyCloudyRainDark.rawValue :
                            WeatherConditions.partlyCloudyRain.rawValue
                    }
                } else if weatherIDInt >= 300 {
                    iconString = darkModeOn ?
                        WeatherConditions.lightRainDark.rawValue : WeatherConditions.lightRain.rawValue
                } else if weatherIDInt >= 200 {
                    iconString = darkModeOn ?
                        WeatherConditions.thunderstormDark.rawValue :
                        WeatherConditions.thunderstorm.rawValue
                }
                completion(currentTempString!, iconString!)
            }
        } catch let error {
            #if DEBUG
                print("got an error parsing the response: \(error)")
            #endif
        }
    }
}
