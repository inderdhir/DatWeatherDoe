//
//  NetworkClient.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class NetworkClient {
    
    func performRequest(url: URL) async throws -> Data {
        try await URLSession.shared.data(from: url).0
    }
}
