//
//  ItemContentCardView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI
#if os(tvOS)
struct TVItemContentCardView: View {
    let item: ItemContent
    private let context = PersistenceController.shared
    @State private var isInWatchlist: Bool = false
    @State private var isWatched = false
    @State private var showConfirmation = false
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.cardImageLarge)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: item.itemContentMedia == .tvShow ? "tv" : "film")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                }
                .overlay {
                    if isInWatchlist {
                        VStack {
                            Spacer()
                            HStack {
                                Text(item.itemTitle)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding()
                                Spacer()
                                if isWatched {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
                                } else {
                                    Image(systemName: "square.stack.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
                                }
                            }
                            .background {
                                Color.black.opacity(0.5)
                                    .mask {
                                        LinearGradient(colors:
                                                        [Color.black,
                                                         Color.black.opacity(0.924),
                                                         Color.black.opacity(0.707),
                                                         Color.black.opacity(0.383),
                                                         Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                            }
                        }
                    } else {
                        VStack {
                            Spacer()
                            HStack {
                                Text(item.itemTitle)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .padding()
                                Spacer()
                            }
                            .background {
                                Color.black.opacity(0.5)
                                    .mask {
                                        LinearGradient(colors:
                                                        [Color.black,
                                                         Color.black.opacity(0.924),
                                                         Color.black.opacity(0.707),
                                                         Color.black.opacity(0.383),
                                                         Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                            }
                        }
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                .aspectRatio(contentMode: .fill)
        }
        .buttonStyle(.card)
        .task {
            withAnimation {
                isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                if isInWatchlist && !isWatched {
                    isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                }
            }
        }
        .modifier(
            ItemContentContextMenu(item: item,
                                   showConfirmation: $showConfirmation,
                                   isInWatchlist: $isInWatchlist,
                                   isWatched: $isWatched)
        )
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 440
    static let imageHeight: CGFloat = 240
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 1
}
#endif
