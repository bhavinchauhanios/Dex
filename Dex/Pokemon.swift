//
//  Pokemon.swift
//  Dex
//
//  Created by Bhavin Chauhan on 06/08/25.
//
//

import Foundation
import SwiftData
import SwiftUI

@Model
public class Pokemon : Decodable {

    @Attribute(.unique) var id: Int
    var name: String
    var attack: Int
    var defense: Int
    var hp: Int
    var shinyImage: Data?
    var shinyURL: URL
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int
    var sprite: URL
    var spriteImage: Data?
    var favorite: Bool = false
    var types: [String]
    var shiny : URL
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case types
        case stats
        case sprites
        
        enum TypeDictionaryKeys: CodingKey{
            
            case type
            
            enum TypeKeys: CodingKey{
                case name
            }
            
        }
        
        enum statDictionaryKeys : CodingKey{
            case baseStat
        }
        
        enum SpriteKeys: String, CodingKey{
            case spriteURL = "frontDefault"
            case shinyURL = "frontShiny"
        }
        
    }
    
    public required init(from decoder: any Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        var decodedTypes: [String] = []
        var typesContainer = try container.nestedUnkeyedContainer(forKey: .types)
        while !typesContainer.isAtEnd {
            let typesDictionaryContainer = try typesContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.self)
            let typeContainer = try typesDictionaryContainer.nestedContainer(keyedBy: CodingKeys.TypeDictionaryKeys.TypeKeys.self, forKey: .type)
            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        
        //Pidgeot: ["normal", "flying"]
        if decodedTypes.count == 2 && decodedTypes[0] == "normal"{
            decodedTypes.swapAt(0,1)
        }
        
        types = decodedTypes
        
        var decodedStats: [Int] = []
        var statsContainer = try container.nestedUnkeyedContainer(forKey: .stats)
        while !statsContainer.isAtEnd {
            let statsDictionaryContainer = try statsContainer.nestedContainer(keyedBy: CodingKeys.statDictionaryKeys.self)
            let stat = try statsDictionaryContainer.decode(Int.self, forKey: .baseStat)
            decodedStats.append(stat)
        }
        
        hp = decodedStats[0]
        attack = decodedStats[1]
        defense = decodedStats[2]
        specialDefense = decodedStats[4]
        specialAttack = decodedStats[3]
        speed = decodedStats[5]
        
        let spriteContainer = try container.nestedContainer(keyedBy: CodingKeys.SpriteKeys.self, forKey: .sprites)
        sprite = try spriteContainer.decode(URL.self, forKey: .spriteURL)
        shiny = try spriteContainer.decode(URL.self, forKey: .shinyURL)
        
    }
    
    var background: ImageResource{
        switch types[0]{
        case "rock", "ground", "steel", "fighting", "ghost", "dark", "psychic":
                .rockgroundsteelfightingghostdarkpsychic
        case "fire", "dragon":
                .firedragon
        case "flying", "bug":
                .flyingbug
        case "ice":
                .ice
        case "water":
                .water
        default:
                .normalgrasselectricpoisonfairy
        }
    
    }
    
    var typeColor: Color{
        Color(types[0].capitalized)
    }
    
    var stats : [Stat]{
        [
            Stat(id: 1, name: "HP", value: hp),
            Stat(id: 2, name: "Attack", value: attack),
            Stat(id: 3, name: "Defense", value: defense),
            Stat(id: 4, name: "Special Attack", value: specialAttack),
            Stat(id: 5, name: "Special Defense", value: specialDefense),
            Stat(id: 6, name: "Speed", value: speed)
        ]
    }
    
    var higestStat : Stat{
        stats.max { $0.value < $1.value }!
    }
    
    struct Stat: Identifiable{
        let id: Int
        let name: String
        let value: Int
    }
    
}
