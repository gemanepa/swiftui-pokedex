//
//  ContentView.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 07/01/2024.
//

import SwiftUI


// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonListView(viewModel: PokemonViewModel())
    }
}
