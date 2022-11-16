//
//  WatchlistView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
        animation: .default)
    private var items: FetchedResults<WatchlistItem>
    @State private var filteredItems = [WatchlistItem]()
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
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
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
            }
            .toolbar {
                ToolbarItem {
                    Picker(selection: $selectedOrder, content: {
                        ForEach(DefaultListTypes.allCases) { sort in
                            Text(sort.title).tag(sort)
                        }
                    }, label: {
                        Label("Sort List", systemImage: "line.3.horizontal.decrease.circle")
                            .labelStyle(.iconOnly)
                    })
                }
            }
            .dropDestination(for: ItemContent.self) { items, _  in
                for item in items {
                    Task {
                        let content = try? await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                        guard let content else { return }
                        PersistenceController.shared.save(content)
                    }
                }
                return true
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}

private struct WatchlistSection: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 240))
    ]
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items) { item in
                    WatchlistItemCard(item: item)
                        .navigationDestination(for: WatchlistItem.self) { item in
                            ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
                        }
                }
            }
            .padding([.top, .bottom])
        } else {
            VStack {
                Spacer()
                CenterHorizontalView {
                    Text("This list is empty.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct WatchlistItemCard: View {
    let item: WatchlistItem
    @State private var isWatched = false
    @State private var isFavorite = false
    @State private var isPin = false
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.image)
                .resizable()
                .placeholder {
                    VStack {
                        if item.itemMedia == .movie {
                            Image(systemName: "film")
                        } else {
                            Image(systemName: "tv")
                        }
                        Text(item.itemTitle)
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                }
                .overlay {
                    ZStack(alignment: .bottom) {
                        VStack {
                            Spacer()
                            ZStack {
                                Color.black.opacity(0.4)
                                    .frame(height: 30)
                                    .mask {
                                        LinearGradient(colors: [Color.black,
                                                                Color.black.opacity(0.924),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 40)
                                    .mask {
                                        VStack(spacing: 0) {
                                            LinearGradient(colors: [Color.black.opacity(0),
                                                                    Color.black.opacity(0.383),
                                                                    Color.black.opacity(0.707),
                                                                    Color.black.opacity(0.924),
                                                                    Color.black],
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            .frame(height: 30)
                                            Rectangle()
                                        }
                                    }
                            }
                        }
                        HStack {
                            Text(item.itemTitle)
                                .font(.callout)
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .padding([.leading, .bottom])
                            Spacer()
                        }
                        
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                .aspectRatio(contentMode: .fill)
                .task {
                    isWatched = item.isWatched
                    isFavorite = item.isFavorite
                    isPin = item.isPin
                }
        }
        .buttonStyle(.plain)
        .modifier(WatchlistItemContextMenu(item: item,
                                           isWatched: $isWatched, isFavorite: $isFavorite,
                                           isPin: $isPin))
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let titleLineLimit: Int = 1
}
