//
//  NetworkClient.swift
//  DatWeatherDoe
//
//  Created by Inder Dhir on 1/14/22.
//  Copyright © 2022 Inder Dhir. All rights reserved.
//

import Foundation

final class NetworkClient {
    
    func performRequest(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(WeatherError.networkError))
                return
            }
            
            completion(.success(data))
        }.resume()
    }
    
    @available(macOS 12.0, *)
    func performRequest(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
