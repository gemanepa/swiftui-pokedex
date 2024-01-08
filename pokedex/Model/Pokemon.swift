//
//  Pokemon.swift
//  pokedex
//
//  Created by Gabriel Ernesto Martinez Canepa on 08/01/2024.
//

import Foundation

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
