//
//  HomeView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showConfirmation = false
    @Environment(\.managedObjectContext) var viewContext
    var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.isLoaded {
                    ProgressView("Loading")
                }
                VStack {
                    ScrollView {
                        UpcomingWatchlist()
                        PinItemsList()
                        ItemContentListView(items: viewModel.trending,
                                            title: "Trending",
                                            subtitle: "Today",
                                            image: "crown",
                                            addedItemConfirmation: $showConfirmation)
                        ForEach(viewModel.sections) { section in
                            ItemContentListView(items: section.results,
                                                title: section.title,
                                                subtitle: section.subtitle,
                                                image: section.image,
                                                addedItemConfirmation: $showConfirmation)
                        }
                        AttributionView()
                    }
                }
                .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
                .navigationDestination(for: ItemContent.self) { item in
                    ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
                }
                .navigationDestination(for: WatchlistItem.self) { item in
                    ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
                }
                .navigationTitle("Home")
                .task {
                    await viewModel.load()
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

private struct UpcomingWatchlist: View {
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
                                                                NSPredicate(format: "contentType == %d", MediaType.movie.toInt)
                                                            ])
                                        ,
                                        NSPredicate(format: "upcomingSeason == %d", true)])
    )
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        UpcomingListView(items: items.filter { $0.image != nil })
    }
}


private struct PinItemsList: View {
    @FetchRequest(
        entity: WatchlistItem.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \WatchlistItem.date, ascending: true),
        ],
        predicate: NSPredicate(format: "isPin == %d", true)
    )
    
    var items: FetchedResults<WatchlistItem>
    var body: some View {
        if !items.isEmpty {
            VStack {
                TitleView(title: "My Pins",
                          subtitle: "Your pinned items",
                          image: "pin")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items) { item in
                            PosterWatchlistItem(item: item)
                                .buttonStyle(.plain)
                                .padding([.leading, .trailing], 4)
                                .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}

private struct PosterWatchlistItem: View {
    let item: WatchlistItem
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.mediumPosterImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        VStack {
                            Text(item.itemTitle)
                                .font(.callout)
                                .lineLimit(1)
                                .foregroundColor(.white)
                                .padding(.bottom)
                            Image(systemName: item.isMovie ? "film" : "tv")
                                .font(.title)
                                .foregroundColor(.white)
                                .opacity(0.8)
                        }
                        .padding()
                    }
                    .frame(width: DrawingConstants.posterWidth,
                           height: DrawingConstants.posterHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.zero)
                .draggable(item)
                .contextMenu {
                    ShareLink(item: item.itemLink)
                    Divider()
                    Button(action: {
                        withAnimation {
                            PersistenceController.shared.markPinAs(item: item)
                        }
                    }, label: {
                        Label("Remove Pin", systemImage: "pin.slash.fill")
                    })
                }
        }
    }
}
