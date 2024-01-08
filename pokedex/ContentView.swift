//
//  ContentView.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 07/01/2024.
//

import SwiftUI
import Combine

// MARK: - Model

struct PokemonList: Codable {
    let count: Int
    let results: [Pokemon]
}

struct Pokemon: Codable, Identifiable, Equatable {
    let name: String
    let url: String
    // Use the content between the last two slashes in the url as the identifier
       var id: String {
           let components = url.components(separatedBy: "/")
           return components.dropLast().last ?? "0"
       }
}

struct PokemonInfo: Codable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let weight: Int
    let height: Int
    let abilities: [Ability]
}

struct PokemonType: Codable {
    let type: Type
}

struct Type: Codable {
    let name: String
}

struct Ability: Codable {
    let ability: AbilityDetail
}

struct AbilityDetail: Codable {
    let name: String
}

// MARK: - ViewModel

class PokemonViewModel: ObservableObject {
    // Published properties to trigger UI updates
    @Published var pokemonList: [Pokemon] = []
    @Published var selectedPokemon: Pokemon?
    @Published var pokemonInfo: PokemonInfo?
    
    private var cancellables: Set<AnyCancellable> = []
    
    // Function to fetch the list of Pokemons
    func fetchPokemons() {
        print("Inside fetchPokemons...") // Log when the function starts

        // Check if the cached data is still valid based on a time limit (e.g., one month)
        if let storedData = UserDefaults.standard.data(forKey: "pokemonList"),
           let cacheTimestamp = UserDefaults.standard.object(forKey: "pokemonListTimestamp") as? Date,
           let cachedPokemonList = try? JSONDecoder().decode(PokemonList.self, from: storedData),
           cacheTimestamp.timeIntervalSinceNow > -30 * 24 * 60 * 60 { // Cache expires after one month
            // Use the cached data
            print("Using cached data")
            self.pokemonList = cachedPokemonList.results
            return
        }

        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1300") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PokemonList.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Fetching pokemons completed successfully")
                case .failure(let error):
                    print("Error fetching pokemons:", error)
                    // Handle error if needed
                }
            } receiveValue: { [weak self] pokemonList in
                print("Received pokemonList with \(pokemonList.results.count) items")
                self?.pokemonList = pokemonList.results

                // Store the data on the device along with the current timestamp
                if let encodedData = try? JSONEncoder().encode(pokemonList) {
                    UserDefaults.standard.set(encodedData, forKey: "pokemonList")
                    UserDefaults.standard.set(Date(), forKey: "pokemonListTimestamp")
                }
            }
            .store(in: &cancellables)
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

// MARK: - Views

struct PokemonListView: View {
    @ObservedObject var viewModel: PokemonViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.pokemonList) { pokemon in
                NavigationLink(destination: PokemonInfoView(viewModel: viewModel, pokemon: pokemon)) {
                    HStack {
                        Text(pokemon.name.capitalized)
                        Spacer()
                    }
                }
            }
            .onAppear {
                            print("Fetching Pokemons...")
                            viewModel.fetchPokemons()
                        }
                        .onChange(of: viewModel.pokemonList) {
                            print("Pokemon List Updated:", viewModel.pokemonList)
                        }
            .navigationTitle("Pokemons")
        }
    }
}

struct PokemonInfoView: View {
    @ObservedObject var viewModel: PokemonViewModel
    var pokemon: Pokemon

    var body: some View {
        VStack {
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
                        .frame(width: 250, height: 250)
                        .padding(.bottom, 10)
                case .failure:
                    // Display an error or placeholder image
                    Image(systemName: "xmark.octagon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding(.bottom, 10)
                @unknown default:
                    // Handle unknown cases
                    EmptyView()
                }
            }

            if let pokemonInfo = viewModel.pokemonInfo {
                Text("ID: \(pokemonInfo.id)")
                Text("Name: \(pokemonInfo.name.capitalized)")
                Text("Types: \(pokemonInfo.types.map { $0.type.name.capitalized }.joined(separator: ", "))")
                Text("Weight: \(pokemonInfo.weight)")
                Text("Height: \(pokemonInfo.height)")
                Text("Abilities: \(pokemonInfo.abilities.map { $0.ability.name.capitalized }.joined(separator: ", "))")
            } else {
                Text("Loading...")
            }
        }
        .onAppear {
            viewModel.selectedPokemon = pokemon
            viewModel.fetchPokemonInfo()
        }
        .navigationTitle("Pokemon Info")
    }
}


// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView(viewModel: PokemonViewModel())
    }
}
