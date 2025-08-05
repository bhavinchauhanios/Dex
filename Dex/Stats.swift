//
//  Stats.swift
//  Dex
//
//  Created by Bhavin Chauhan on 05/08/25.
//

import SwiftUI
import Charts

struct Stats: View {
    
    var pokemon : Pokemon
    
    var body: some View {
        
        Chart(pokemon.stats){ stat in
            BarMark(
                x: .value("Value", stat.value),
                y: .value("Stats", stat.name)
            )
            .annotation(position: .trailing){
                Text("\(stat.value)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.top, -5)
            }
        }
        .frame(height: 200)
        .padding([.horizontal, .bottom])
        .foregroundStyle(pokemon.typeColor)
        .chartXScale(domain: 0...pokemon.higestStat.value+10)
    }
}

#Preview {
    Stats(pokemon: PersistenceController.previewPokemon)
}
