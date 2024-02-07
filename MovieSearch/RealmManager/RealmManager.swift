//
//  RealmManager.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 01.02.2024.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private var realm: Realm?
    
    private init() {
        do {
            self.realm = try Realm()
        } catch {
            print("Error creating instance Realm: \(error)")
        }
    }
    
    func getMoviesList() -> Results<MovieListRealmModel>? {
        return self.realm?.objects(MovieListRealmModel.self)
    }
    
    func addMovie(movie: MovieListRealmModel) {
        do {
            try self.realm?.write {
                self.realm?.add(movie)
            }
        } catch {
            print("Error adding movie to Realm: \(error)")
        }
    }
    
    func deleteMovie(movieImdbID: String) {
        if let movieToDelete = realm?.objects(MovieListRealmModel.self).filter({ $0.movieImdbID == movieImdbID }).first {
            do {
                try self.realm?.write{
                    self.realm?.delete(movieToDelete)
                }
            } catch {
                print("Error deleting movie from Realm: \(error)")
            }
        }
    }
}
