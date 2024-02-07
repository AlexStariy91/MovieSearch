//
//  SearchViewController.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 26.01.2024.
//

import UIKit
import Kingfisher
import RealmSwift
import SkeletonView

protocol SearchViewControllerDelegate: AnyObject {
    func applyFavoritesChangesAtFavoritesVC()
}

class SearchViewController: UIViewController {
    
    @IBOutlet private weak var noSearchResultsLabel: UILabel!
    @IBOutlet private weak var moviesList: UITableView!
    
    private let tableViewFooterSpinner = UIActivityIndicatorView(style: .medium)
    private var searchResult = [Movie]()
    private var totalResults: Int = 0
    private var searchValue: String = ""
    private var pageNumberForMoviesListRequest = 1
    private let networkManager = NetworkManager.shared
    private let realmManager = RealmManager.shared
    private var realmMoviesList: Results<MovieListRealmModel>?
    weak var delegate: SearchViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        moviesList.isSkeletonable = true
        setupSearchBar()
        registerCell()
        realmMoviesList = realmManager.getMoviesList()
        addObserver()
        setFavoritesControllerDelegateToSelf()
    }
    
    private func registerCell() {
        moviesList.register(UINib(nibName: "MoviesListTableViewCell", bundle: nil), forCellReuseIdentifier: "MoviesListTableViewCell")
    }
    
    private func setupSearchBar() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Enter movie title"
        searchController.definesPresentationContext = true
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
    }
    
    private func footerSpinner(spin: Bool, tableView: UITableView) {
        let tableViewFooterSpinnerTest = UIActivityIndicatorView(style: .medium)
        tableViewFooterSpinnerTest.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        switch spin {
        case true:
            tableView.tableFooterView = tableViewFooterSpinnerTest
            tableViewFooterSpinnerTest.startAnimating()
        case false:
            tableView.tableFooterView = .none
            tableViewFooterSpinnerTest.stopAnimating()
        }
    }
    
    // Mark search result movies as favorite if they are already in favorites list
    private func markFavorites(movieListFromApi: MovieListAPIModel){
        guard let realmMoviesList = self.realmMoviesList, let searchResults = movieListFromApi.searchMoviesResult else {return}
        for movie in searchResults {
            if let index = realmMoviesList.firstIndex(where: { $0.movieImdbID == movie.imdbID }){
                movie.isInFavorites = realmMoviesList[index].isInFavorites
            }
        }
    }
    
    private func setFavoritesControllerDelegateToSelf() {
        if let favoritesNavigationController = self.tabBarController?.viewControllers?[1] as? UINavigationController{
            if let favoritesViewController = favoritesNavigationController.viewControllers[0] as? FavoritesViewController {
                favoritesViewController.delegate = self
            }
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyFavoritesChangesFromDetailsVC), name: NSNotification.Name("FavoritesHasBeenChangedFromDetailsVC"), object: nil)
    }
    
    @objc private func applyFavoritesChangesFromDetailsVC(_ notification: Notification) {
        if !searchResult.isEmpty{
            guard let movieID = notification.userInfo?["movieID"] as? String,
                  let isInFavorites = notification.userInfo?["isInFavorites"] as? Bool
            else {return}
            applyFavoritesChangesAtSearchVC(movieID: movieID, isInFavorites: isInFavorites)
        }
    }
    
    private func stopSkeleton() {
        moviesList.stopSkeletonAnimation()
        view.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("FavoritesHasBeenChangedFromDetailsVC"), object: nil)
    }
}

// MARK: SkeletonTableViewDataSource, UITableViewDelegate
extension SearchViewController: UITableViewDelegate, SkeletonTableViewDataSource {
    
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "MoviesListTableViewCell"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResult.count != 0 {
            noSearchResultsLabel.isHidden = true
            moviesList.isHidden = false
            return searchResult.count
        }
        noSearchResultsLabel.isHidden = false
        moviesList.isHidden = true
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesListTableViewCell", for: indexPath) as! MoviesListTableViewCell
        cell.delegate = self
        cell.fillUpCellWithDataFromAPI(movieFromApi: searchResult[indexPath.row], indexPathRow: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let movieDetailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        movieDetailsVC.imdbID = searchResult[indexPath.row].imdbID
        movieDetailsVC.isInFavorites = searchResult[indexPath.row].isInFavorites
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == searchResult.count - 1 else {return}
        if searchResult.count < totalResults {
            footerSpinner(spin: true, tableView: tableView)
            pageNumberForMoviesListRequest += 1
            networkManager.getMovieList(searchValue: searchValue, pageNumber: pageNumberForMoviesListRequest) { [weak self] result in
                switch result {
                case .success(let data):
                    do{
                        let movies = try JSONDecoderManager.shared.decode(MovieListAPIModel.self, from: data)
                        self?.markFavorites(movieListFromApi: movies)
                        self?.searchResult.append(contentsOf: movies.searchMoviesResult ?? [])
                        DispatchQueue.main.async {
                            self?.moviesList.reloadData()
                        }
                    } catch let error as JSONDecodeError{
                        print("Error decoding JSON \(error)")
                        self?.footerSpinner(spin: false, tableView: tableView)
                    } catch {
                        print("Unexpected error \(error)")
                        self?.footerSpinner(spin: false, tableView: tableView)
                    }
                case .failure(let error):
                    self?.pageNumberForMoviesListRequest -= 1
                    self?.footerSpinner(spin: false, tableView: tableView)
                    print("Error \(error)")
                }
            }
        } else {
            footerSpinner(spin: false, tableView: tableView)
        }
    }
}


// MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let result = searchBar.text {
            searchValue = result
            pageNumberForMoviesListRequest = 1
        } else { return }
        
        DispatchQueue.main.async {
            self.noSearchResultsLabel.isHidden = true
            self.moviesList.isHidden = false
            self.moviesList.showAnimatedGradientSkeleton(usingGradient: .init(baseColor: .lightGray), animation: nil, transition: .crossDissolve(0.25))
        }
        
        networkManager.getMovieList(searchValue: searchValue, pageNumber: pageNumberForMoviesListRequest) { [weak self] result in
            switch result {
            case.success(let data):
                do{
                    let movies = try JSONDecoderManager.shared.decode(MovieListAPIModel.self, from: data)
                    if let searchError = movies.error {
                        DispatchQueue.main.async {
                            self?.showAlert(with: searchError)
                            self?.stopSkeleton()
                            self?.moviesList.isHidden = true
                            self?.noSearchResultsLabel.isHidden = false
                            return
                        }
                    }
                    self?.totalResults = Int(movies.totalResults ?? "") ?? 1
                    self?.markFavorites(movieListFromApi: movies)
                    self?.searchResult = movies.searchMoviesResult ?? []
                    DispatchQueue.main.async {
                        self?.stopSkeleton()
                        self?.moviesList.reloadData()
                    }
                } catch let error as JSONDecodeError{
                    print("Error decoding JSON \(error)")
                    self?.stopSkeleton()
                } catch {
                    self?.stopSkeleton()
                    print("Unexpected error \(error)")
                }
            case .failure(let error):
                print("Error \(error)")
                self?.stopSkeleton()
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.view.sk.isSkeletonActive {
            DispatchQueue.main.async {
                self.stopSkeleton()
            }
        }
    }
}


// MARK: MoviesListTableViewCellDelegate
extension SearchViewController: MoviesListTableViewCellDelegate {
    
    func didToggleFavoriteStateAtCell(tag: Int) {
        let index = IndexPath(row: tag, section: 0)
        DispatchQueue.main.async {
            self.moviesList.reloadRows(at: [index], with: .none)
        }
    }
    
    func didManageFavorites(movie: MovieListRealmModel) {
        guard let realmMoviesList = self.realmMoviesList else {
            print("Error getting movies list from Realm")
            return
        }
        if !realmMoviesList.contains(where: { $0.movieImdbID == movie.movieImdbID }) {
            realmManager.addMovie(movie: movie)
        } else {
            realmManager.deleteMovie(movieImdbID: movie.movieImdbID)
        }
        delegate?.applyFavoritesChangesAtFavoritesVC()
    }
}

// MARK: FavoritesViewControllerDelegate
extension SearchViewController: FavoritesViewControllerDelegate {
    func applyFavoritesChangesAtSearchVC(movieID: String, isInFavorites: Bool) {
        if let index = searchResult.firstIndex(where: { $0.imdbID == movieID }) {
            searchResult[index].isInFavorites = isInFavorites
            DispatchQueue.main.async {
                self.moviesList.reloadData()
            }
        }
    }
}
