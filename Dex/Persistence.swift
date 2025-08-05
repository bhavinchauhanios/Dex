//
//  Persistence.swift
//  Dex
//
//  Created by Bhavin Chauhan on 04/08/25.
//

import CoreData

struct PersistenceController {
    //The thing that contols our database
    static let shared = PersistenceController()

    static var previewPokemon: Pokemon{
        
        let context = PersistenceController.preview.container.viewContext
        
        let fetchReqest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchReqest.fetchLimit = 1
        
        let results = try! context.fetch(fetchReqest)
        
        return results.first!
        
    }
    
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
     
        let newPokemon = Pokemon(context: viewContext)
        newPokemon.id = 1
        newPokemon.name = "bulbasaur"
        newPokemon.types = ["grass, poison"]
        newPokemon.hp = 45
        newPokemon.attack = 49
        newPokemon.defense = 49
        newPokemon.specialAttack = 65
        newPokemon.specialDefense = 65
        newPokemon.speed = 45
        newPokemon.sprite = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png")
        newPokemon.shinyURL = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/1.png")
        newPokemon.favorite = false

        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        return result
    }()

    //
    let container: NSPersistentContainer

    // regular Init function
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Dex")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
