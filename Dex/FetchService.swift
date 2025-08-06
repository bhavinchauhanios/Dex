//
//  FeatchService.swift
//  BBQuotes
//
//  Created by Bhavin Chauhan on 01/08/25.
//

import Foundation

struct FetchService{
    
    private enum FetchError : Error{
        case badResponse
    }
    
    private let baseURL =  URL(string: "https://pokeapi.co/api/v2/pokemon")!
    
    //https://breaking-bad-api-six.vercel.app/api/quotes/random?production=Breaking+Bad
    func fetchPokemon(_ id:Int) async throws -> Pokemon {
        
        //BuildFetch URL
        let fetchURL = baseURL.appending(path: String(id))
        
        //Fetch Data
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        
        // Handle Response
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw FetchError.badResponse
        }
        
        // Decode Data
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let pokemon = try decoder.decode(Pokemon.self, from: data)
        
        print("Fetched Pokemon: \(pokemon.id): \(pokemon.name.capitalized)")
        // Return Quote
        return pokemon
        
    }
    
    
    
}
