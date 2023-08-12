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
                                    NSPredicate(format: "isArchive == %d", false),
                                    NSPredicate(format: "contentType == %d", MediaType.movie.toInt)
                                ])
            ,
            NSCompoundPredicate(type: .and,
                                subpredicates: [
                                    NSPredicate(format: "upcomingSeason == %d", true),
                                    NSPredicate(format: "isArchive == %d", false)
                                ])])
    )
    var items: FetchedResults<WatchlistItem>
    @StateObject private var settings = SettingsStore.shared
    @Binding var shouldReload: Bool
    var body: some View {
		list(items: items.filter { $0.image != nil && $0.itemReleaseDate > Date() }.sorted(by: { $0.itemReleaseDate < $1.itemReleaseDate}))
			.onAppear {
				updateItems(items: items.filter { $0.itemReleaseDate < Date() })
			}
    }
	
	private func updateItems(items: [WatchlistItem]) {
		if items.isEmpty { return }
		Task {
			for item in items {
				let content = try? await NetworkService.shared.fetchItem(id: item.itemId, type: item.itemMedia)
				if let content {
					PersistenceController.shared.update(item: content)
				}
			}
		}
	}
    
    @ViewBuilder
	private func list(items: [WatchlistItem]) -> some View {
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
                .padding(.leading, 64)
#endif
                ScrollViewReader { proxy in
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
                                    .padding(.leading, item.id == items.first!.id ? 64 : 0)
                                    .padding(.trailing, item.id == items.last!.id ? 64 : 0)
                                    .padding(.vertical)
                                    .padding([.leading, .trailing], 4)
                                    .buttonStyle(.card)
#endif
                            }
                        }
                    }
                    .onChange(of: shouldReload) { _ in
                        guard let firstItem = items.first else { return }
                        withAnimation {
                            proxy.scrollTo(firstItem.id, anchor: .topLeading)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func card(item: WatchlistItem) -> some View {
#if os(tvOS)
        VStack {
            image(for: item)
                .buttonStyle(.card)
            HStack {
                Text(item.itemTitle)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            if let info = item.itemGlanceInfo {
                HStack {
                    Text(info)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            Spacer()
        }
        .frame(width: DrawingConstants.cardWidth)
#else
        if item.image != nil {
            if settings.isCompactUI {
                VStack {
                    image(for: item)
                    HStack {
                        Text(item.itemTitle)
                            .font(.caption)
                            .lineLimit(2)
                        Spacer()
                    }
                    if let info = item.itemGlanceInfo {
                        HStack {
                            Text(info)
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .frame(width: DrawingConstants.compactCardWidth)
            } else {
                image(for: item)
            }
        } else {
            EmptyView()
        }
#endif
    }
    
    private func image(for item: WatchlistItem) -> some View {
        NavigationLink(value: item) {
            WebImage(url: item.image, options: .highPriority)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "popcorn.fill")
                            .font(.title)
                            .fontWidth(.expanded)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                }
                .aspectRatio(contentMode: .fill)
#if !os(tvOS)
                .overlay {
                    if !settings.isCompactUI {
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
                }
#endif
                .frame(width: settings.isCompactUI ? DrawingConstants.compactCardWidth : DrawingConstants.cardWidth,
                       height: settings.isCompactUI ? DrawingConstants.compactCardHeight : DrawingConstants.cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.cardRadius, style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .transition(.opacity)
                .applyHoverEffect()
        }
    }
}

struct UpcomingWatchlist_Previews: PreviewProvider {
    static var previews: some View {
        UpcomingWatchlist(shouldReload: .constant(false))
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let cardWidth: CGFloat = 420
    static let cardHeight: CGFloat = 240
#else
    static let cardWidth: CGFloat = 280
    static let cardHeight: CGFloat = 160
#endif
    static let cardRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2.5
    static let lineLimits: Int = 1
    static let compactCardWidth: CGFloat = 160
    static let compactCardHeight: CGFloat = 100
}
