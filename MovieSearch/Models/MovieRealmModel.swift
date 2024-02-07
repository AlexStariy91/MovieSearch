//
//  MovieRealmModel.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 31.01.2024.
//

import Foundation
import RealmSwift

class MovieListRealmModel: Object {
    @Persisted var movieTitle: String = ""
    @Persisted var movieYear: String = ""
    @Persisted var moviePoster: String = ""
    @Persisted var movieImdbID: String = ""
    @Persisted var isInFavorites = false
}
