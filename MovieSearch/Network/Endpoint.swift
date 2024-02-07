//
//  Endpoint.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 28.01.2024.
//

import Foundation

struct Endpoint {
    private let queryItems: [URLQueryItem]
    private let apiKey = "4bfbff27"
    private let baseURL = "https://www.omdbapi.com/"
    var url: URL? {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [URLQueryItem(name: "apikey", value: apiKey),
        URLQueryItem(name: "type", value: "movie")]
        components?.queryItems?.append(contentsOf: queryItems)
        return components?.url
    }
}

extension Endpoint {
    static func searchMoviesList(searchValue: String, pageNumber: Int) -> Endpoint {
        Endpoint(queryItems: [URLQueryItem(name: "s", value: searchValue),
                              URLQueryItem(name: "page", value: String(pageNumber))])
    }
    
    static func searchMovieDetails(movieId: String) -> Endpoint {
        Endpoint(queryItems: [URLQueryItem(name: "i", value: movieId), URLQueryItem(name: "plot", value: "full")])
    }
}
