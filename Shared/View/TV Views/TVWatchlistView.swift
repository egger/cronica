//
//  WatchlistView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI
#if os(tvOS)
struct TVWatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var showFilters = false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Watchlist")
                            .font(.title3)
                        Text(selectedOrder.title)
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    Spacer()
                    Button {
                        showFilters.toggle()
                    } label: {
                        Label("Filters",
                              systemImage: "line.3.horizontal.decrease.circle")
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.bordered)
                    .padding()
                }
                switch selectedOrder {
                case .released:
                    WatchlistSection(items: items.filter { $0.isReleased })
                case .upcoming:
                    WatchlistSection(items: items.filter { $0.isUpcoming })
                case .production:
                    WatchlistSection(items: items.filter { $0.isInProduction })
                case .watched:
                    WatchlistSection(items: items.filter { $0.isWatched })
                case .favorites:
                    WatchlistSection(items: items.filter { $0.isFavorite })
                case .pin:
                    WatchlistSection(items: items.filter { $0.isPin })
                case .archive:
                    WatchlistSection(items: items.filter { $0.isArchive })
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetails(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .sheet(isPresented: $showFilters) {
                VStack {
                    ForEach(DefaultListTypes.allCases) { list in
                        Button {
                            selectedOrder = list
                            showFilters.toggle()
                        } label: {
                            HStack {
                                Image(systemName: list == selectedOrder ? "checkmark.circle.fill" : "circle")
                                    .padding(.trailing)
                                Spacer()
                                Text(list.title)
                                    .padding(.trailing)
                            }
                            .frame(maxWidth: 400)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        TVWatchlistView()
    }
}

private struct WatchlistSection: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 460))
    ]
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items) { item in
                    TVWatchlistItemCard(item: item)
                }
            }
            .padding(.top)
        } else {
            Spacer()
            Text("This list is empty.")
            Spacer()
        }
    }
}
#endif
