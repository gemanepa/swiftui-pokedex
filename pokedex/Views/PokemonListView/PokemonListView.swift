//
//  PokemonListView.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 08/01/2024.
//

import SwiftUI


struct PokemonListView: View {
    @ObservedObject var viewModel: PokemonViewModel
    @State private var visiblePokemon: [Pokemon] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText)

                List(filteredPokemon) { pokemon in
                    NavigationLink(destination: PokemonInfoView(viewModel: viewModel, pokemon: pokemon)) {
                        HStack {
                            AsyncImageLoader(pokemon: pokemon, isVisible: visiblePokemon.contains(pokemon))
                                .frame(width: 75, height: 75)
                                .padding()
                                .onAppear {
                                    visiblePokemon.append(pokemon)
                                }
                                .onDisappear {
                                    if let index = visiblePokemon.firstIndex(of: pokemon) {
                                        visiblePokemon.remove(at: index)
                                    }
                                }
                            Text(pokemon.name.capitalized)
                        }
                    }
                }
                .onAppear {
                    print("Fetching Pokemons...")
                    viewModel.fetchPokemons()
                }
                .navigationTitle("Pokemons")
            }
        }
    }

    // Add a computed property to filter the Pokémon based on the search text
    private var filteredPokemon: [Pokemon] {
        if searchText.isEmpty {
            return viewModel.pokemonList
        } else {
            return viewModel.pokemonList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    struct AsyncImageLoader: View {
        let pokemon: Pokemon
        let isVisible: Bool

        var body: some View {
            if isVisible {
                AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")) { phase in
                    switch phase {
                    case .empty:
                        // Placeholder or loading view
                        ProgressView()
                    case .success(let image):
                        // Successfully loaded image
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                    case .failure:
                        // Display an error or placeholder image
                        Image(systemName: "xmark.octagon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 75, height: 75)
                    @unknown default:
                        // Handle unknown cases
                        EmptyView()
                    }
                }
            } else {
                // Placeholder view for non-visible items
                Color.clear.frame(width: 75, height: 75)
            }
        }
    }
}
