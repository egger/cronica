//
//  UpcomingWatchlist.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 03/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpcomingWatchlist: View {
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
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        list(items: items.filter { $0.image != nil })
    }
    
    @ViewBuilder
    func list(items: [WatchlistItem]) -> some View {
        if !items.isEmpty {
            VStack {
#if !os(tvOS)
                NavigationLink(value: items) {
                    TitleView(title: "Upcoming",
                              subtitle: "From Watchlist",
                              showChevron: true)
                }
                .buttonStyle(.plain)
#else
                TitleView(title: "Upcoming",
                          subtitle: "From Watchlist",
                          showChevron: false)
                .padding(.leading, 32)
#endif
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items) { item in
                            card(item: item)
#if !os(tvOS)
                                .padding(.leading, item.id == items.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                                .padding(.bottom)
                                .padding(.top, 8)
                                .padding([.leading, .trailing], 4)
                                .buttonStyle(.plain)
#else
                                .padding(.leading, item.id == items.first!.id ? 32 : 0)
                                .padding(.trailing, item.id == items.last!.id ? 32 : 0)
                                .padding(.vertical)
                                .padding([.leading, .trailing], 4)
                                .buttonStyle(.card)
#endif
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func card(item: WatchlistItem) -> some View {
        if item.image != nil {
            NavigationLink(value: item) {
                WebImage(url: item.image, options: .highPriority)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.gray.gradient)
                            Color.black.opacity(0.4)
                            Image(systemName: item.itemMedia == .tvShow ? "tv" : "film")
                                .foregroundColor(.secondary)
                        }
                    }
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        ZStack(alignment: .bottom) {
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
                            if let info = item.itemGlanceInfo {
                                VStack(alignment: .leading) {
                                    Spacer()
                                    HStack {
                                        Text(item.itemTitle)
                                            .fontWeight(.semibold)
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .lineLimit(DrawingConstants.lineLimits)
                                            .padding(.leading)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(info)
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .lineLimit(DrawingConstants.lineLimits)
                                            .padding(.leading)
                                            .padding(.bottom, 8)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 2)
                            } else {
                                VStack(alignment: .leading) {
                                    Spacer()
                                    HStack {
                                        Text(item.itemTitle)
                                            .fontWeight(.semibold)
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .lineLimit(DrawingConstants.lineLimits)
                                            .padding()
                                        Spacer()
                                    }
                                    
                                }
                                .padding(.horizontal, 2)
                            }
                            
                        }
                    }
                    .frame(width: settings.isCompactUI ? DrawingConstants.compactCardWidth : DrawingConstants.cardWidth,
                           height: settings.isCompactUI ? DrawingConstants.compactCardHeight : DrawingConstants.cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.cardRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                    .transition(.opacity)
                    .applyHoverEffect()
            }
        } else {
            EmptyView()
        }
    }
}

struct UpcomingWatchlist_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingWatchlist()
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let cardWidth: CGFloat = 460
    static let cardHeight: CGFloat = 260
#else
    static let cardWidth: CGFloat = 280
    static let cardHeight: CGFloat = 160
#endif
    static let cardRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2.5
    static let lineLimits: Int = 1
    static let compactCardWidth: CGFloat = 200
    static let compactCardHeight: CGFloat = 120
}
