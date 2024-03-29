# Movie Search App
"MovieSearch" has the ability to discover, explore, and manage your favorite movies. Powered by the Open Movie Database [OMDB](http://www.omdbapi.com) API, users can browse through a collection of movies, view details about films, and save their selections to favorites.

<img src="https://github.com/AlexStariy91/MovieSearch/assets/133584636/87b6598c-e712-41e7-89a4-eb9408b18cfe" width="232" height="480" /> <img src="https://github.com/AlexStariy91/MovieSearch/assets/133584636/c3259db8-74d1-46b9-9bd8-1d53821d38d7" width="232" height="480" /> <img src="https://github.com/AlexStariy91/MovieSearch/assets/133584636/47918aa4-32e5-4c4a-98dc-aaa7eb83c632" width="232" height="480" />
<img src="https://github.com/AlexStariy91/MovieSearch/assets/133584636/e08a8137-ea1b-4bbf-85fd-f7961b3b65bd" width="232" height="480" /> ![MovieSearchGif](https://github.com/AlexStariy91/MovieSearch/assets/133584636/5c54d6e8-c5b5-4091-8f64-35610082afa8)

# Features
- **Search:** Find movies by title.
- **Detailed information:** Access detailed information about each movie, including year, runtime, IMDB rating, Director, Cast, and Plot.
- **Favorites:** Save your favorite movies for easy access later.

# Requirements
- iOS 15.0 and above
- Cocoapods [more info how to install](https://guides.cocoapods.org/using/getting-started.html)
```
sudo gem install cocoapods
```

# Installation
1. Clone the repository to your local machine.
```
git clone git@github.com:AlexStariy91/MovieSearch.git
```
2. Open the terminal and navigate to the project's root directory.
```
cd MovieSearch
```
3. Install the pods into the project by running the "pod install" command.
```
pod install
```
4. After the installation, open the .xcworkspace file generated by CocoaPods in XCode.
```
open .
```
5. Build and run the project on a simulator or a physical iOS device.

# Usage
- Use the search bar to enter the title of the movie you're looking for.
- Browse through the search results and tap on the movie to view movie details.
- The ability to save or delete a movie to favorites is present both in the Search tab and details screen by tapping the star icon.
- Access your favorites list movies by navigating to the Favorites tab where you also can delete movies by swiping the row to the left or by tapping the edit button.
