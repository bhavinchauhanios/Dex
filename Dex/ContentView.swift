//
//  ContentView.swift
//  Dex
//
//  Created by Bhavin Chauhan on 04/08/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokedex: FetchedResults<Pokemon>
    
    let fetcher = FetchService()
    
    

    var body: some View {
        NavigationView {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink {
                        Text(pokemon.name?.capitalized ?? "no name")
                    } label: {
                        Text(pokemon.name ?? "no name")
                    }
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
                
            }
            Text("Select an item")
        }
    }
    
    private func getPokemon(){
        
        Task{
            for id in 1..<152{
                do{
                    let fetchPokemon = try await fetcher.fetchPokemon(id)
                    
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchPokemon.id
                    pokemon.name = fetchPokemon.name
                    pokemon.attack = fetchPokemon.attack
                    pokemon.defense = fetchPokemon.defense
                    pokemon.hp = fetchPokemon.hp
                    pokemon.specialAttack = fetchPokemon.specialAttack
                    pokemon.specialDefense = fetchPokemon.specialDefense
                    pokemon.speed = fetchPokemon.speed
                    pokemon.sprite = fetchPokemon.sprite
                    pokemon.shiny = fetchPokemon.shiny
                    pokemon.types = fetchPokemon.types
                    
                    try viewContext.save()

                }catch{
                    print(error)
                }
            }
        }
        
    }

}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
