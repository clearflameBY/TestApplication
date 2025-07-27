//
//  NetworkManager.swift
//  FoodDeliveryApp
//
//  Created by Илья Степаненко on 25.07.25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
}

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    func request<T: Decodable>(url: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                print("Decoding Error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
