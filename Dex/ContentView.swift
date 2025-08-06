//
//  ContentView.swift
//  Dex
//
//  Created by Bhavin Chauhan on 04/08/25.
//

import SwiftUI
import CoreData
import Kingfisher

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all

    @FetchRequest<Pokemon>(sortDescriptors: [SortDescriptor(\.id)],animation: .default) private var pokedex
    
    @State private var searchText = ""
    @State private var filterByFavourites = false
    
    let fetcher = FetchService()
    
    private var dynamicPredicate : NSPredicate{
        var predicates : [NSPredicate] = []
        
        //Search Predicate
        if !searchText.isEmpty{
            predicates.append(NSPredicate(format: "name contains[c] %@",searchText))
        }
        
        if filterByFavourites{
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        //Filter  by favoirite predicate
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    var body: some View {
        if all.isEmpty{
            ContentUnavailableView {
                Label("No Pokemon", image: .nopokemon)
            }description:{
                Text("There aren't any Pokemon yet.\nFetch some Pokemon to get started!")
            }actions: {
                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right"){
                    getPokemon(for: pokedex.count + 1)
                }.buttonStyle(.borderedProminent)
            }
        }else{
            NavigationStack {
                List {
                    Section{
                        
                        ForEach(pokedex) { pokemon in
                            NavigationLink(value: pokemon) {
                                HStack(spacing: 16) {
                                    
                                    KFImage(pokemon.sprite)
                                        .placeholder {
                                            ProgressView()
                                        }
                                        .retry(maxCount: 3, interval: .seconds(3)) // Optional: retry failed loads
                                        .cacheOriginalImage()
                                        .fade(duration: 0.25)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(pokemon.name?.capitalized ?? "")
                                                .fontWeight(.bold)

                                            if pokemon.favorite {
                                                Image(systemName: "star.fill")
                                                    .foregroundStyle(.yellow)
                                            }
                                        }

                                        HStack {
                                            ForEach(pokemon.types ?? [], id: \.self) { type in
                                                Text(type.capitalized)
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundStyle(.black)
                                                    .padding(.horizontal, 13)
                                                    .padding(.vertical, 5)
                                                    .background(Color(type.description.capitalized))
                                                    .clipShape(Capsule())
                                            }
                                        }
                                    }
                                }
                            }
                            .swipeActions(edge:.leading) {
                                Button {
                                    pokemon.favorite.toggle()
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        print("Failed to save context: \(error)")
                                    }
                                } label: {
                                    Label(
                                        pokemon.favorite ? "Remove from Favourites" : "Add to Favourites",
                                        systemImage: "star"
                                    )
                                }
                                .tint(pokemon.favorite ? .gray : .yellow)
                            }
                        }
                    }footer:{
                 
                        if all.count < 151{
                            
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!\nFetch the rest of the Pokemon.")
                            } actions: {
                                Button("Fetch Pokemon", systemImage: "antenna.radiowaves.left.and.right") {
                                    getPokemon(for: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
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
                
                .onChange(of: filterByFavourites){
                    pokedex.nsPredicate = dynamicPredicate
                }
                
                .navigationDestination(for: Pokemon.self, destination: { pokemon in
                                    PokemonDetail()
                                    .environmentObject(pokemon)
                })
                
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavourites.toggle()
                        }label:{
                            Label("Filter By Favourites", systemImage: filterByFavourites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                    
                }
                
            }
        }
    }
    
    private func getPokemon(for id: Int){
        
        Task{
            for i in id..<152{
                do{
                    let fetchPokemon = try await fetcher.fetchPokemon(i)
                    
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
                    pokemon.shinyURL = fetchPokemon.shiny
                    pokemon.types = fetchPokemon.types
                    print("Fetched pokemon\(i): \(pokemon.name ?? "")")
                    try viewContext.save()

                }catch{
                    print(error)
                }
            }
            storeSprites()
        }
        
    }
    
    private func storeSprites(){
        
        for pokemon in all{
            Task{
                do{
                    pokemon.spriteImage = try await URLSession.shared.data(from: pokemon.sprite!).0
                    pokemon.shinyImage = try await URLSession.shared.data(from: pokemon.shinyURL!).0
                    
                    try viewContext.save()
                    
                    print("Sprites stored: \(pokemon.id): \(pokemon.name?.capitalized ?? "")")
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
