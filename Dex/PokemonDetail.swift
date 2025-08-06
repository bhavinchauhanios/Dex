//
//  PokemonDetail.swift
//  Dex
//
//  Created by Bhavin Chauhan on 05/08/25.
//

import SwiftUI
import Kingfisher

struct PokemonDetail: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var pokemon: Pokemon
    @State private var showShiny = false
    
    var body: some View {
        
        ScrollView {
    
            ZStack{
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black,radius: 6)
                   
                KFImage(showShiny ? pokemon.shinyURL : pokemon.sprite)
                    .placeholder {
                        ProgressView()
                    }
                    .retry(maxCount: 3, interval: .seconds(3))
                    .cacheOriginalImage()
                    .fade(duration: 0.25)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .padding(.top, 50)
                    .shadow(color: .black, radius: 6)
                
            }
            
            //Tags
            HStack{
                ForEach(pokemon.types!, id:\.self){ type in
                    Text(type.capitalized)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                        .shadow(color: .white, radius: 1)
                        .padding(.vertical, 7)
                        .padding(.horizontal)
                        .background(Color(type.capitalized))
                        .clipShape(Capsule())
                }
                Spacer()
                
                Button {
                    pokemon.favorite.toggle()
                    do{
                        try viewContext.save()
                    }catch{
                        print(error)
                    }
                } label: {
                    Image(systemName: pokemon.favorite ? "star.fill" : "star")
                        .fontWeight(.regular)
                        .tint(.yellow)
                }

            }
            .padding()
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -7)
            Stats(pokemon: pokemon)
            
        }.navigationTitle(pokemon.name!.capitalized)
        
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        showShiny.toggle()
                    } label: {
                        Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.inverse")
                            .tint(showShiny ? .yellow : .primary)
                    }

                }
                
            }
        
    }
}

#Preview {
    NavigationStack{
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
