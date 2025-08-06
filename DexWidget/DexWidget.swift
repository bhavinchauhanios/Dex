//
//  DexWidget.swift
//  DexWidget
//
//  Created by Bhavin Chauhan on 06/08/25.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: TimelineProvider {
    
    var randomPokemon: Pokemon{
        var results: [Pokemon] = []
        
        do{
            results = try PersistenceController.shared.container.viewContext.fetch(Pokemon.fetchRequest())
        }catch{
            print("Coudn't fetch")
        }
        
        if let randomPokemon = results.randomElement(){
            return randomPokemon
        }
        
        return PersistenceController.previewPokemon
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 10 {
            
            let entryPokemon = randomPokemon
            
            let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset * 5, to: currentDate)!
            
            if let imageData = entryPokemon.spriteImage,
               let uiImage = UIImage(data: imageData) {
                let entry = SimpleEntry(
                    date: entryDate,
                    name: entryPokemon.name ?? "Unknown",
                    types: entryPokemon.types ?? [],
                    sprite: Image(uiImage: uiImage)
                )
                entries.append(entry)
            }
            
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let types : [String]
    let sprite: Image
    
    static var placeholder : SimpleEntry{
        SimpleEntry(date: .now, name: "bulabasur", types: ["grass","poison"], sprite: Image(.bulbasaur))
    }
    
    static var placeholder2 : SimpleEntry{
        SimpleEntry(date: .now, name: "mew", types: ["psychic","poison"], sprite: Image(.mew))
    }
}

struct DexWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var widgetSize
    var pokemonImage : some View{
        entry.sprite
        .interpolation(.none)
        .resizable()
        .scaledToFit()
        .shadow(color: .black, radius: 6)
    }
    
    var typeView : some View{
        ForEach(entry.types, id: \.self) { type in
            Text(type.capitalized)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(type.capitalized))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
        }
    }
    
    var body: some View {
        
        switch widgetSize {
        case .systemMedium:
            HStack{
                pokemonImage
             
                Spacer()
                
                
                VStack(alignment: .leading){
                    
                    Text(entry.name.capitalized)
                        .font(.title)
                        .padding(.vertical, 1)
                    
                    HStack(spacing: 10) {
                        typeView
                    }
                }.layoutPriority(1)
                
                Spacer()
            }
            
        case .systemLarge:
            
            ZStack{
                pokemonImage
                
                
                VStack(alignment: .leading){
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    
                    HStack{
                        typeView
                    }
                    
                }
            }
            
        default:
            pokemonImage
        }
        
    }
}

struct DexWidget: Widget {
    let kind: String = "DexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                DexWidgetEntryView(entry: entry)
                    .foregroundStyle(.black)
                    .containerBackground(Color(entry.types[0].capitalized), for: .widget)
            } else {
                DexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Pokemon")
        .description("See a random Pokemon.")
    }
}

#Preview(as: .systemSmall) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemMedium) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemLarge) {
    DexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
