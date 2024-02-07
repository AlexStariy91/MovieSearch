//
//  MoviesListModel.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 26.01.2024.
//

import Foundation

class MovieListAPIModel: Codable {
    let searchMoviesResult: [Movie]?
    let error: String?
    let totalResults: String?
    
    enum CodingKeys: String, CodingKey {
        case searchMoviesResult = "Search"
        case error = "Error"
        case totalResults
    }
}

class Movie: Codable {
    let title, imdbID, poster, year: String?
    var isInFavorites = false
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case imdbID
        case poster = "Poster"
        case year = "Year"
    }
}

extension Movie {
    func convertToRealmModel() -> MovieListRealmModel {
        let movieRealmModel = MovieListRealmModel()
        movieRealmModel.movieImdbID = self.imdbID ?? ""
        movieRealmModel.movieTitle = self.title ?? ""
        movieRealmModel.movieYear = self.year ?? ""
        movieRealmModel.moviePoster = self.poster ?? ""
        movieRealmModel.isInFavorites = self.isInFavorites
        return movieRealmModel
    }
}
