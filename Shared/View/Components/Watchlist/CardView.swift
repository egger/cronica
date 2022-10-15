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
    var body: some View {
        if item.image != nil {
            NavigationLink(value: item) {
                WebImage(url: item.image, options: .highPriority)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Color.black.opacity(0.4)
                            Rectangle().fill(.thickMaterial)
                            Image(systemName: "film")
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
                    .frame(width: DrawingConstants.cardWidth,
                           height: DrawingConstants.cardHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.cardRadius, style: .continuous))
                    .shadow(radius: DrawingConstants.shadowRadius)
                    .contextMenu {
                        ShareLink(item: item.itemLink)
                        Divider()
                        Button(role: .destructive, action: {
                            remove(item: item)
                        }, label: {
                            Label("Remove from watchlist", systemImage: "trash")
                        })
                    }
                    .padding([.leading, .trailing], 4)
                    .transition(.opacity)
                    .hoverEffect(.lift)
                    .draggable(item)
            }
        } else {
            EmptyView()
        }
    }
    
    private func remove(item: WatchlistItem) {
        HapticManager.shared.mediumHaptic()
        if item.notify {
            notification.removeNotification(identifier: item.notificationID)
        }
        withAnimation {
            viewContext.delete(item)
            if viewContext.hasChanges { try? viewContext.save() }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(item: WatchlistItem.example)
    }
}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 280
    static let cardHeight: CGFloat = 160
    static let cardRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2.5
    static let lineLimits: Int = 1
}
