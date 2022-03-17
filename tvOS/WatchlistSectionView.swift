//
//  WatchlistSectionView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct WatchlistSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            Section {
                ScrollView([.horizontal]) {
                    LazyHGrid(rows: [GridItem()]) {
                        ForEach(items) { item in
                            NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.itemId, type: item.media)) {
                                Button {
                                     
                                } label: {
                                    AsyncImage(url: item.image) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView(item.itemTitle)
                                    }
                                }
                                .frame(width: 400, height: 320)
                                .buttonStyle(CardButtonStyle())
                            }
                        }
                    }
                }
            } header: {
                Text(title)
            }
//            Section {
//                ForEach(items) { item in
//                    NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.itemId, type: item.media)) {
//                        ItemView(title: item.itemTitle, url: item.image, type: item.media, inSearch: false)
//                    }
//                }
//            } header: {
//                Text(NSLocalizedString(title, comment: ""))
//            }
        }
    }
}

//struct ShelfView: View {
//    var body: some View {
//        ScrollView([.horizontal]) {
//            LazyHGrid(rows: [GridItem()]) {
//                ForEach(playlists, id: \.self) { playlist in
//                    Button(action: goToPlaylist) {
//                        Image(playlist.coverImage)
//                            .resizable()
//                            .frame(…)
//                    }
//                    .buttonStyle(CardButtonStyle())
//                }
//            }
//        }
//    }
//}

//struct WatchlistSectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        WatchlistSectionView()
//    }
//}
