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
        zipCode: String,
        completion: @escaping (_ temperature: String?, _ icon: NSImage?) -> Void
        ) {

        var urlComps = URLComponents(string: apiUrl)
        urlComps?.queryItems = [
            URLQueryItem(name: "zip", value: zipCode),
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

    /// Location-based weather
    func getWeather(
        location: CLLocationCoordinate2D,
        completion: @escaping (_ temperature: String?, _ icon: NSImage?) -> Void
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
        completion: (_ temperature: String?, _ icon: NSImage?) -> Void
        ) {

        guard let response = try? JSONDecoder().decode(WeatherResponse.self, from: data),
            let temperature = response.temperatureString,
            let icon = response.icon else {
                print("Unable to parse weather response")
                completion(nil, NSImage(named: "Sunny"))
                return
        }

        let image = NSImage(named: icon)
        image?.isTemplate = true
        completion(temperature, image)
    }
}
