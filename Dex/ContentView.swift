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

    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default) private var pokedex
    
    @State private var searchText = ""
    
    let fetcher = FetchService()
    
    private var dynamicPredicate : NSPredicate{
        var predicates : [NSPredicate] = []
        
        //Search Predicate
        if !searchText.isEmpty{
            predicates.append(NSPredicate(format: "name contains[c] %@",searchText))
        }
        
        //Filter  by favoirite predicate
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    var body: some View {
        
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width:100, height:100)
                        
                        VStack(alignment: .leading) {
                            Text(pokemon.name!.capitalized)
                                .fontWeight(.bold)
                            
                            HStack{
                                ForEach(pokemon.types!, id:\.self){ type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.black)
                                        .padding(.horizontal, 13)
                                        .padding(.vertical,5)
                                        .background(Color(type.description.capitalized))
                                        .clipShape(.capsule)
                                }
                            }
                        }
                    }
                }
            }
            
            .navigationTitle("Pokedox")
            .searchable(text: $searchText, prompt: "Find a pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredicate
            }
            
            .navigationDestination(for: Pokemon.self, destination: { pokemon in
                Text(pokemon.name?.capitalized ?? "no name")
            })
                                   
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
            
        }
    }
    
    private func getPokemon(){
        
        Task{
            for id in 0..<152{
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
