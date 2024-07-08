//
//  NetworkClient.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

protocol NetworkClientType {
    func performRequest(url: URL) async throws -> Data
}

final actor NetworkClient: NetworkClientType {
    func performRequest(url: URL) async throws -> Data {
        do {
            return try await URLSession.shared.data(from: url).0
        } catch {
            throw WeatherError.networkError
        }
    }
}
