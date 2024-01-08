//
//  PokemonViewModel.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 08/01/2024.
//

import Foundation
import Combine

class PokemonViewModel: ObservableObject {
    // Published properties to trigger UI updates
    @Published var pokemonList: [Pokemon] = []
    @Published var selectedPokemon: Pokemon?
    @Published var pokemonInfo: PokemonInfo?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // Function to fetch the list of Pokemons
    func fetchPokemons() {
        print("Inside fetchPokemons...") // Log when the function starts

        if let cachedPokemonList = loadCachedPokemonList() {
            // Use the cached data if available and still valid
            print("Using cached data")
            self.pokemonList = cachedPokemonList.results
        } else {
            fetchPokemonList()
        }
    }

    private func loadCachedPokemonList() -> PokemonList? {
        guard let storedData = UserDefaults.standard.data(forKey: "pokemonList"),
              let cacheTimestamp = UserDefaults.standard.object(forKey: "pokemonListTimestamp") as? Date,
              let cachedPokemonList = try? JSONDecoder().decode(PokemonList.self, from: storedData),
              cacheTimestamp.timeIntervalSinceNow > -30 * 24 * 60 * 60 // Cache expires after one month
        else {
            return nil
        }

        return cachedPokemonList
    }

    private func fetchPokemonList() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1275") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonList.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.handlePokemonListCompletion(completion)
            } receiveValue: { [weak self] pokemonList in
                self?.handlePokemonListSuccess(pokemonList)
            }
            .store(in: &cancellables)
    }

    private func handlePokemonListSuccess(_ pokemonList: PokemonList) {
        print("Received pokemonList with \(pokemonList.results.count) items")
        self.pokemonList = pokemonList.results

        // Store the data on the device along with the current timestamp
        if let encodedData = try? JSONEncoder().encode(pokemonList) {
            UserDefaults.standard.set(encodedData, forKey: "pokemonList")
            UserDefaults.standard.set(Date(), forKey: "pokemonListTimestamp")
        }
    }

    private func handlePokemonListCompletion(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            print("Fetching pokemons completed successfully")
        case .failure(let error):
            print("Error fetching pokemons:", error)
            // Handle error if needed
        }
    }
    
    // Function to fetch detailed information about a selected Pokemon
    func fetchPokemonInfo() {
        guard let selectedPokemon = selectedPokemon,
              let url = URL(string: selectedPokemon.url) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonInfo.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                // Handle error if needed
            } receiveValue: { [weak self] pokemonInfo in
                self?.pokemonInfo = pokemonInfo
            }
            .store(in: &cancellables)
    }
}
