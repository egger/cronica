//
//  WatchlistView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    var body: some View {
        VStack {
            ScrollView {
                List {
                    ForEach(items) { item in
                        WatchlistItemView(content: item)
                    }
                }
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
