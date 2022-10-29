//
//  WatchlistView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
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
    @AppStorage("selectedOrder") private var selectedOrder: DefaultListTypes = .released
    @State private var showFilters = false
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    switch selectedOrder {
                    case .released:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .upcoming:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .production:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .watched:
                        Text(selectedOrder.title)
                            .font(.title)
                    case .favorites:
                        Text(selectedOrder.title)
                            .font(.title)
                    }
                    Spacer()
                    Button(action: {
                        showFilters.toggle()
                    }, label: {
                        Label("List Filters",
                              systemImage: "line.3.horizontal.decrease.circle")
                    })
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
                }
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetails(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
            }
            .sheet(isPresented: $showFilters) {
                VStack {
                    ForEach(DefaultListTypes.allCases) { list in
                        Button(list.title) {
                            selectedOrder = list
                            showFilters.toggle()
                        }
                        .buttonStyle(.plain)
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

struct WatchlistSection: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 360))
    ]
    let items: [WatchlistItem]
    var body: some View {
        if !items.isEmpty {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(items) { item in
                    WatchlistItemCard(item: item)
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
                                    .frame(height: 50)
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
                                    .frame(height: 70)
                                    .mask {
                                        VStack(spacing: 0) {
                                            LinearGradient(colors: [Color.black.opacity(0),
                                                                    Color.black.opacity(0.383),
                                                                    Color.black.opacity(0.707),
                                                                    Color.black.opacity(0.924),
                                                                    Color.black],
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            .frame(height: 50)
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
        .buttonStyle(.card)
        .ignoresSafeArea(.all)
        .modifier(WatchlistItemContextMenu(item: item,
                                           isWatched: $isWatched, isFavorite: $isFavorite,
                                           isPin: $isPin))
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 200
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let titleLineLimit: Int = 1
}

struct WatchlistItemContextMenu: ViewModifier {
    let item: WatchlistItem
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    private let context = PersistenceController.shared
    private let notification = NotificationManager.shared
    func body(content: Content) -> some View {
        return content
            .contextMenu {
                watchedButton
                favoriteButton
                pinButton
                deleteButton
            }
    }
    
    private var watchedButton: some View {
        Button(action: {
            withAnimation {
                withAnimation {
                    isWatched.toggle()
                }
                context.updateMarkAs(id: item.itemId, type: item.itemMedia, watched: !item.watched)
            }
        }, label: {
            Label(item.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: item.isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button(action: {
            withAnimation {
                withAnimation {
                    isFavorite.toggle()
                }
                context.updateMarkAs(id: item.itemId, type: item.itemMedia, favorite: !item.favorite)
            }
        }, label: {
            Label(item.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: item.isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        })
    }
    
    private var pinButton: some View {
        Button(action: {
            PersistenceController.shared.updatePin(items: [item.notificationID])
            isPin.toggle()
        }, label: {
            Label(isPin ? "Unpin Item" : "Pin Item",
                  systemImage: isPin ? "pin.slash.fill" : "pin.fill")
        })
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            if item.notify {
                notification.removeNotification(identifier: item.notificationID)
            }
            withAnimation {
                context.delete(item)
            }
        }, label: {
            Label("Remove", systemImage: "trash")
        })
    }
}

