//
//  MoviesListTableViewCell.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 28.01.2024.
//

import UIKit

protocol MoviesListTableViewCellDelegate: AnyObject {
    func didToggleFavoriteStateAtCell(tag: Int)
    func didManageFavorites(movie: MovieListRealmModel)
}

class MoviesListTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var highlightView: UIView!
    @IBOutlet private weak var movieYear: UILabel!
    @IBOutlet private weak var movieTitle: UILabel!
    @IBOutlet private weak var posterImage: UIImageView!
    @IBOutlet private weak var favoritesButton: UIButton!
    
    private var movie: Movie?
    weak var delegate: MoviesListTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func fillUpCellWithDataFromAPI(movieFromApi: Movie, indexPathRow: Int) {
        self.movie = movieFromApi
        favoritesButton.setImage(UIImage(systemName: "star" + (movieFromApi.isInFavorites ? ".fill" : "")), for: .normal)
        favoritesButton.tag = indexPathRow
        posterImage.installPoster(from: movieFromApi.poster)
        movieTitle.text = movieFromApi.title
        movieYear.text = movieFromApi.year
    }
    
    func fillUpCellWithDataFromRealm(movieFromRealm: MovieListRealmModel, indexPathRow: Int){
        favoritesButton.isHidden = true
        posterImage.installPoster(from: movieFromRealm.moviePoster)
        favoritesButton.tag = indexPathRow
        movieTitle.text = movieFromRealm.movieTitle
        movieYear.text = movieFromRealm.movieYear
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.4) {
            self.highlightView.alpha = highlighted ? 0.3 : 0
        }
    }
    
    @IBAction func manageFavorites(_ sender: UIButton) {
        let vibrate = UIImpactFeedbackGenerator(style: .medium)
        vibrate.impactOccurred()
        vibrate.prepare()
        guard let movie else {return}
        movie.isInFavorites = !movie.isInFavorites
        delegate?.didToggleFavoriteStateAtCell(tag: favoritesButton.tag)
        let movieRealmModel = movie.convertToRealmModel()
        delegate?.didManageFavorites(movie: movieRealmModel)
    }
}
