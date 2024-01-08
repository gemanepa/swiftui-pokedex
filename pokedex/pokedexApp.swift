//
//  pokedexApp.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 07/01/2024.
//

import SwiftUI

@main
struct PokedexApp: App {
    var body: some Scene {
        WindowGroup {
            PokemonListView(viewModel: PokemonViewModel()) // Assuming PokemonListView is your main view
        }
    }
}

