//
//  UpcomingListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 18/07/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpcomingListView: View {
    static let tag: Screens? = .upcoming
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSCompoundPredicate(type: .or, subpredicates: [
            NSCompoundPredicate(type: .and,
                                subpredicates: [
                                    NSPredicate(format: "schedule == %d", ItemSchedule.soon.toInt),
                                    NSPredicate(format: "notify == %d", true),
									NSPredicate(format: "isArchive == %d", false),
                                    NSPredicate(format: "contentType == %d", MediaType.movie.toInt)
                                ])
            ,
            NSPredicate(format: "upcomingSeason == %d", true), NSPredicate(format: "isArchive == %d", false)])
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        NavigationStack {
            list(items: items.filter { $0.backCompatibleCardImage != nil })
        }
    }
    
    private func list(items: [WatchlistItem]) -> some View {
        VStack {
            if !items.isEmpty {
                List {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            itemRow(item)
                        }
                    }
                }
            } else {
                Text("Your upcoming items will appear here.")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Upcoming")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: WatchlistItem.self) { item in
            ItemContentView(id: item.itemId,
                            title: item.itemTitle,
                            type: item.itemMedia,
                            image: item.itemImage)
        }
    }
    
    private func itemRow(_ item: WatchlistItem) -> some View {
        HStack {
            WebImage(url: item.backCompatibleCardImage)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "popcorn.fill")
                            .fontWidth(.expanded)
                            .foregroundColor(.white.opacity(0.8))
                            .padding([.horizontal, .bottom])
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            VStack(alignment: .leading) {
                Text(item.itemTitle)
                    .font(.caption)
                    .lineLimit(2)
                Text(item.itemGlanceInfo ?? String())
                    .font(.caption)
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.leading, 2)
            Spacer()
        }
    }
}

struct UpcomingListView_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingListView()
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 8
    static let textLimit: Int = 1
}
