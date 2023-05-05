//
//  CronicaWidget.swift
//  CronicaWidget
//
//  Created by Alexandre Madeira on 26/08/22.
//

import WidgetKit
import SwiftUI
import SDWebImageSwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ItemContentEntry {
        ItemContentEntry(date: Date(), item: ItemContent.examples)
    }

    func getSnapshot(in context: Context, completion: @escaping (ItemContentEntry) -> ()) {
        let entry = ItemContentEntry(date: Date(), item: ItemContent.examples)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            let nextUpdate = Date().addingTimeInterval(86400) // 24 hours in seconds
            do {
                let result = try await NetworkService.shared.fetchItems(from: "trending/all/day")
                var content = [ItemContent]()
                for item in result.shuffled().prefix(4) {
                    let image = await NetworkService.shared.downloadImageData(from: item.posterImage)
                    let itemContent = ItemContent(id: item.id,
                                                  title: item.title,
                                                  name: item.name,
                                                  posterPath: item.posterPath,
                                                  backdropPath: item.backdropPath,
                                                  data: image)
                    content.append(itemContent)
                }
                let entry = ItemContentEntry(date: .now, item: content)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
                completion(timeline)
            } catch {
                print("❌ error: \(error.localizedDescription)")
            }
        }
    }
}

struct ItemPosterImage: Codable, Identifiable {
    var id: Int
    var image: Data?
}

struct ItemContentEntry: TimelineEntry {
    let date: Date
    let item: [ItemContent]
}

struct CronicaWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack(alignment: .leading) {
            ItemContentList(items: entry.item)
        }
        .padding()
    }
}

@main
struct CronicaWidget: Widget {
    let kind: String = "CronicaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            CronicaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Trending")
        .description("Shows movies and TV Shows trending from TMDb.")
        .supportedFamilies([.systemMedium])
    }
}

struct CronicaWidget_Previews: PreviewProvider {
    static var previews: some View {
        CronicaWidgetEntryView(entry: ItemContentEntry(date: Date(), item: [ItemContent.placeholder]))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
