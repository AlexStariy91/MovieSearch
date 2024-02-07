//
//  MovieModel.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 26.01.2024.
//

import Foundation

class MovieDetailsModel: Codable {
    let imdbID, title, year, runtime, poster, director, plot, imdbRating, cast: String
    var isInFavorites = false
    
    enum CodingKeys: String, CodingKey {
        case imdbID
        case title = "Title"
        case year = "Year"
        case runtime = "Runtime"
        case poster = "Poster"
        case director = "Director"
        case plot = "Plot"
        case imdbRating
        case cast = "Actors"
    }
}
