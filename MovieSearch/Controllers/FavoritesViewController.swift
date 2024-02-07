//
//  FavoritesViewController.swift
//  MovieSearch
//
//  Created by Alexander Starodub on 28.01.2024.
//

import UIKit
import RealmSwift

protocol FavoritesViewControllerDelegate: AnyObject {
    func applyFavoritesChangesAtSearchVC(movieID: String, isInFavorites: Bool)
}

class FavoritesViewController: UIViewController {

    @IBOutlet private weak var emptyFavoritesLabel: UILabel!
    @IBOutlet private weak var favoritesMoviesList: UITableView!
    
    private let networkManager = NetworkManager.shared
    private let realmManager = RealmManager.shared
    private var favoritesMoviesListRealm: Results<MovieListRealmModel>?
    weak var delegate: FavoritesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favoritesMoviesListRealm = realmManager.getMoviesList()
        registerCell()
        setSearchViewControllerDelegateToSelf()
        addObserver()
    }
   
    private func registerCell() {
        favoritesMoviesList.register(UINib(nibName: "MoviesListTableViewCell", bundle: nil), forCellReuseIdentifier: "MoviesListTableViewCell")
    }
    
    private func setSearchViewControllerDelegateToSelf() {
        if let searchNavigationController = self.tabBarController?.viewControllers?[0] as? UINavigationController{
            if let searchViewController = searchNavigationController.viewControllers[0] as? SearchViewController {
                searchViewController.delegate = self
            }
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(applyFavoritesChanges), name: NSNotification.Name("FavoritesHasBeenChangedFromDetailsVC"), object: nil)
    }
    
    @objc private func applyFavoritesChanges(_ notification: Notification) {
        DispatchQueue.main.async {
            self.favoritesMoviesList.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("FavoritesHasBeenChangedFromDetailsVC"), object: nil)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension FavoritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let favoritesMoviesListRealm = self.favoritesMoviesListRealm,
           favoritesMoviesListRealm.count != 0 {
                self.favoritesMoviesList.isHidden = false
                self.emptyFavoritesLabel.isHidden = true
                self.navigationItem.leftBarButtonItem = self.editButtonItem
            return favoritesMoviesListRealm.count
        }
                self.favoritesMoviesList.isHidden = true
                self.emptyFavoritesLabel.isHidden = false
                self.navigationItem.leftBarButtonItem = .none
            return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesListTableViewCell", for: indexPath) as! MoviesListTableViewCell
        if let favoritesMoviesListRealm = self.favoritesMoviesListRealm {
            cell.fillUpCellWithDataFromRealm(movieFromRealm: favoritesMoviesListRealm[indexPath.row], indexPathRow: indexPath.row)
        } 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let movieDetailsVC = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        guard let favoritesMoviesListRealm else {return}
        movieDetailsVC.imdbID = favoritesMoviesListRealm[indexPath.row].movieImdbID
        movieDetailsVC.isInFavorites = favoritesMoviesListRealm[indexPath.row].isInFavorites
        navigationController?.pushViewController(movieDetailsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.setEditing(true, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        self.setEditing(false, animated: false)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        DispatchQueue.main.async {
            self.favoritesMoviesList.setEditing(editing, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let favoritesMoviesListRealm else {return}
            let editingRow = favoritesMoviesListRealm[indexPath.row]
            delegate?.applyFavoritesChangesAtSearchVC(movieID: editingRow.movieImdbID, isInFavorites: !editingRow.isInFavorites)
            self.realmManager.deleteMovie(movieImdbID: editingRow.movieImdbID)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .left)
            if favoritesMoviesListRealm.count == 0 {
                    self.setEditing(false, animated: false)
            }
                tableView.endUpdates()
        }
    }
}

extension FavoritesViewController: SearchViewControllerDelegate {
    func applyFavoritesChangesAtFavoritesVC() {
        DispatchQueue.main.async {
            self.favoritesMoviesList.reloadData()
        }
    }
}
