//
//  DetailsViewController.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 28.01.2024.
//

import UIKit
import SkeletonView

class DetailsViewController: UIViewController {
    @IBOutlet private weak var movieTitle: UILabel!
    @IBOutlet private weak var movieYear: UILabel!
    @IBOutlet private weak var movieRuntime: UILabel!
    @IBOutlet private weak var moviePoster: UIImageView!
    @IBOutlet private weak var movieRating: UILabel!
    @IBOutlet private weak var movieDirector: UILabel!
    @IBOutlet private weak var movieCast: UILabel!
    @IBOutlet private weak var moviePlot: UILabel!
    
    private let realmManager = RealmManager.shared
    private let networkManager = NetworkManager.shared
    private var currentMovieDetails: MovieDetailsModel?
    var imdbID: String?
    var isInFavorites: Bool = false
    private var favoritesButtonImage: UIImage {
        return UIImage(systemName: "star" + (isInFavorites ? ".fill" : "")) ?? UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        self.tabBarController?.tabBar.isHidden = true
        customizingNavigationBar()
        startSkeleton()
        getMovieDetailsFromApi()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func customizingNavigationBar() {
        let favoritesButton = UIBarButtonItem(image: favoritesButtonImage, style: .plain, target: self, action: #selector(onTapFavoritesButton))
        navigationItem.rightBarButtonItem = favoritesButton
    }
    
    @objc private func onTapFavoritesButton() {
        let vibrate = UIImpactFeedbackGenerator(style: .medium)
        vibrate.impactOccurred()
        vibrate.prepare()
        guard let currentMovieDetails else {return}
        isInFavorites = !isInFavorites
        DispatchQueue.main.async {
            self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star" + (self.isInFavorites ? ".fill" : "")) ?? UIImage()
        }
        let movie = convertToRealmModel(movieToConvert: currentMovieDetails)
        let userInfo: [String: Any] = ["movieID" : movie.movieImdbID, "isInFavorites" : movie.isInFavorites]
        switch movie.isInFavorites {
        case false:
            realmManager.deleteMovie(movieImdbID: movie.movieImdbID)
        case true:
            realmManager.addMovie(movie: movie)
        }
        NotificationCenter.default.post(name: NSNotification.Name("FavoritesHasBeenChangedFromDetailsVC"), object: nil, userInfo: userInfo)
    }
    
    private func convertToRealmModel(movieToConvert: MovieDetailsModel) -> MovieListRealmModel {
        let movie = MovieListRealmModel()
        movie.isInFavorites = self.isInFavorites
        movie.movieImdbID = movieToConvert.imdbID
        movie.moviePoster = movieToConvert.poster
        movie.movieTitle = movieToConvert.title
        movie.movieYear = movieToConvert.year
        return movie
    }
    
    private func startSkeleton() {
        DispatchQueue.main.async {
            let labelsToStartSkeleton = [self.movieTitle, self.movieYear, self.movieRuntime, self.movieRating, self.movieDirector, self.movieCast, self.moviePlot]
            
            for label in labelsToStartSkeleton {
                label?.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray), animation: nil, transition: .crossDissolve(0.25))
            }
            
            self.moviePoster.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray), animation: nil, transition: .crossDissolve(0.25))
        }
    }
    
    private func stopSkeleton() {
        let labelsToStopSkeleton = [self.movieTitle, self.movieYear, self.movieRuntime, self.movieRating, self.movieDirector, self.movieCast, self.moviePlot]
            
            for label in labelsToStopSkeleton {
                label?.hideSkeleton()
            }
            self.moviePoster.hideSkeleton()
    }
   
    private func getMovieDetailsFromApi() {
        guard let imdbID = self.imdbID else {return}
        networkManager.getMovieDetails(searchValue: imdbID){ [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let movieDetails = try JSONDecoderManager.shared.decode(MovieDetailsModel.self, from: data)
                    self?.currentMovieDetails = movieDetails
                    DispatchQueue.main.async {
                        self?.stopSkeleton()
                        self?.fillUpDetailsWithData()
                    }
                } catch let error as JSONDecodeError{
                    self?.stopSkeleton()
                    print("Error decoding JSON \(error)")
                } catch {
                    self?.stopSkeleton()
                    print("Unexpected error \(error)")
                }
            case .failure(let error):
                self?.stopSkeleton()
                print("Error \(error)")
            }
        }
    }
    
    private func setAttributedTextToLabels(label: UILabel, bold: String, regular: String) {
        let attributedText = NSMutableAttributedString()
        let nameText = NSAttributedString(string: bold, attributes: [NSAttributedString.Key.font: UIFont.monospacedDigitSystemFont(ofSize: 17, weight: .medium)])
        let bodyText = NSAttributedString(string: regular, attributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.label])
        attributedText.append(nameText)
        attributedText.append(bodyText)
        label.attributedText = attributedText
    }
    
    private func fillUpDetailsWithData() {
        if let currentMovieDetails = self.currentMovieDetails {
            self.moviePoster.installPoster(from: currentMovieDetails.poster)
            self.movieTitle.text = currentMovieDetails.title
            setAttributedTextToLabels(label: movieYear, bold: "Year: ", regular: currentMovieDetails.year)
            setAttributedTextToLabels(label: movieRuntime, bold: "Runtime: ", regular: currentMovieDetails.runtime)
            setAttributedTextToLabels(label: movieRating, bold: "Rating IMDB: ", regular: currentMovieDetails.imdbRating)
            setAttributedTextToLabels(label: movieDirector, bold: "Director: ", regular: currentMovieDetails.director)
            setAttributedTextToLabels(label: movieCast, bold: "Cast: ", regular: currentMovieDetails.cast)
            setAttributedTextToLabels(label: moviePlot, bold: "Plot: ", regular: currentMovieDetails.plot)
        }
    }
}
