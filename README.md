
# Pokedex App

## Overview

Pokedex is a simple SwiftUI iOS app that allows users to explore a list of Pokémon and view detailed information about each Pokémon. The app utilizes the PokeAPI to fetch information about Pokémon.

## Features

### 1. List of Pokémon

-   Displays a list of Pokémon with their names.
-   Uses a combination of SwiftUI's `List` and `NavigationLink` for navigation.

### 2. Pokémon Details

-   Allows users to tap on a Pokémon in the list to view detailed information.
-   Fetches and displays additional information about the selected Pokémon, including ID, name, types, weight, height, and abilities.

### 3. Caching Pokémon List

-   Implements caching to store the list of Pokémon locally for improved performance and reduced network requests.
-   Uses UserDefaults to cache the Pokémon list and includes a timestamp to determine if the cache is still valid.

### 4. Lazy Loading and Asynchronous Image Loading

-   Utilizes lazy loading to optimize performance by only loading data for the visible items.
-   Implements asynchronous image loading using SwiftUI's `AsyncImage` for displaying Pokémon images.

## Installation

1.  Clone the repository.
2.  Open the project in Xcode.
3.  Build and run the app on a simulator or a physical device.

## Dependencies

-   SwiftUI
-   Combine
-   PokeAPI ([https://pokeapi.co/](https://pokeapi.co/))

## License

This project is licensed under the [MIT License](https://chat.openai.com/c/LICENSE.md). Feel free to use and modify the code as needed.

## Acknowledgments

-   Pokémon data provided by [PokeAPI](https://pokeapi.co/).
-   SwiftUI and Combine documentation and community.
