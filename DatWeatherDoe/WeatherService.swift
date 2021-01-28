//
//  WeatherRetriever.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/30/16.
//  Copyright © 2016 Inder Dhir. All rights reserved.
//

import CoreLocation
import AppKit

enum TemperatureUnit: String {
    case fahrenheit, celsius
}

class WeatherService {

    public static let shared = WeatherService()

    private let apiUrl = "https://api.openweathermap.org/data/2.5/weather"
    private let appId: String

    private init() {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType:"plist"),
            let plist = NSDictionary(contentsOfFile: filePath),
            let appId = plist["OPENWEATHERMAP_APP_ID"] as? String else {
            fatalError("Unable to find OpenWeatherMap APP ID")
        }
        self.appId = appId
    }

    /// Zipcode-based weather
    func getWeather(
        zipCode: String?,
        latLong: String?,
        completion: @escaping (_ temperature: String?, _ location: String?, _ icon: NSImage?) -> Void
        ) {

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "appid", value: appId)
        ]
        if let zipCode = zipCode, !zipCode.isEmpty {
            queryItems.append(URLQueryItem(name: "zip", value: zipCode))
        } else if let latLong = latLong, !latLong.isEmpty {
            let latLongCombo = latLong.split(separator: ",")
            guard latLongCombo.count == 2 else {
                print("Incorrect format for lat/lon")
                completion("Incorrect location", "Unknown", nil)
                return
            }

            queryItems.append(contentsOf: [
                URLQueryItem(name: "lat", value: String(latLongCombo[0])),
                URLQueryItem(name: "lon", value: String(latLongCombo[1]))
            ])
        } else {
            print("Unable to get zipcode or lat/lon for fetching weather")
            completion("Error getting weather", "Unknown", nil)
            return
        }

        var urlComps = URLComponents(string: apiUrl)
        urlComps?.queryItems = queryItems
        guard let url = urlComps?.url else {
            fatalError("Unable to construct URL for zipcode/lat,long based weather")
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    print(error.localizedDescription)
                    completion("Error", "Unknown", nil)
                }
                return
            }

            self?.parseResponse(data, completion: completion)
        }.resume()
    }

    /// Location-based weather
    func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (_ temperature: String?, _ location: String?, _ icon: NSImage?) -> Void
        ) {

        var urlComps = URLComponents(string: apiUrl)
        urlComps?.queryItems = [
            URLQueryItem(name: "lat", value: String(describing: location.latitude)),
            URLQueryItem(name: "lon", value: String(describing: location.longitude)),
            URLQueryItem(name: "appid", value: appId)
        ]
        guard let url = urlComps?.url else {
            fatalError("Unable to construct URL for zipcode based weather")
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }

            self?.parseResponse(data, completion: completion)
        }.resume()
    }

    private func parseResponse(
        _ data: Data,
        completion: (_ temperature: String?, _ location: String?, _ icon: NSImage?) -> Void
        ) {
        guard let response = try? JSONDecoder().decode(WeatherResponse.self, from: data),
            let weather = response.weatherString,
            let location = response.locationString,
            let icon = response.icon else {
            print("Unable to parse weather response:", String(decoding: data, as: UTF8.self))
            completion("Error", "Unknown", nil)
            return
        }

        let image = NSImage(named: icon)
        image?.isTemplate = true
        completion(weather, location, image)
    }
}
