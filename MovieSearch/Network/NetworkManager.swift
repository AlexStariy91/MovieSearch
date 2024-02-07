//
//  NetworkManager.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 26.01.2024.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let session = URLSession.shared
    
    func getMovieList(searchValue: String, pageNumber: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        let endpoint = Endpoint.searchMoviesList(searchValue: searchValue, pageNumber: pageNumber)
        getRequest(endpoint: endpoint, completion: completion)
    }
    
    func getMovieDetails(searchValue: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let endpoint = Endpoint.searchMovieDetails(movieId: searchValue)
        getRequest(endpoint: endpoint, completion: completion)
    }
    
    private func getRequest(endpoint: Endpoint, completion: @escaping (Result<Data, Error>) -> Void){
        guard let url = endpoint.url else {
            completion(.failure(APIError.invalidURL))
            return
        }
        let task = session.dataTask(with: URLRequest(url: url)) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(APIError.invalidResponse))
                    return
                }
                
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(APIError.emptyResponse))
                }
            }
        }
        task.resume()
    }
    
}

// MARK: - Error Handling
extension NetworkManager {
    enum APIError: Error {
        case invalidURL
        case invalidResponse
        case emptyResponse
    }
}
