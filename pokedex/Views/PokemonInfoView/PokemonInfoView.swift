//
//  PokemonInfoView.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 08/01/2024.
//

import SwiftUI

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

