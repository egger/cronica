//
//  CardView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//  swiftlint:disable trailing_whitespace

import SwiftUI
import SDWebImageSwiftUI

struct CardView: View {
    let item: WatchlistItem
    private let notification = NotificationManager.shared
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
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
                    .contextMenu {
#if os(iOS) || os(macOS)
                        ShareLink(item: item.itemLink)
#endif
                        Divider()
                        Button(role: .destructive) {
                            remove(item: item)
                        } label: {
                            Label("Remove from watchlist", systemImage: "trash")
                        }
                    }
                    .padding([.leading, .trailing], 4)
                    .transition(.opacity)
                    .applyHoverEffect()
#if os(iOS) || os(macOS)
                    .draggable(item)
#endif
            }
        } else {
            EmptyView()
        }
    }
    
    private func remove(item: WatchlistItem) {
        if item.notify {
            notification.removeNotification(identifier: item.notificationID)
        }
        withAnimation(.easeInOut) {
            viewContext.delete(item)
            if viewContext.hasChanges { try? viewContext.save() }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(item: .example)
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
