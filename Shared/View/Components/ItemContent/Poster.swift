//
//  Poster.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct Poster: View {
    let item: ItemContent
    private let context = PersistenceController.shared
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @Binding var addedItemConfirmation: Bool
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.posterImageMedium, options: .highPriority)
                .resizable()
                .placeholder {
                    PosterPlaceholder(title: item.itemTitle, type: item.itemContentMedia)
                }
                .aspectRatio(contentMode: .fill)
                .overlay {
                    if isInWatchlist {
                        VStack {
                            Spacer()
                            HStack {
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
                                if item.posterImageMedium != nil {
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
                }
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.zero)
                .applyHoverEffect()
                .itemContentContextMenu(item: item,
                                        isWatched: $isWatched,
                                        showConfirmation: $addedItemConfirmation,
                                        isInWatchlist: $isInWatchlist)
                .task {
                    withAnimation {
                        isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                        if isInWatchlist && !isWatched {
                            isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                        }
                    }
                }
#if os(iOS) || os(macOS)
                .draggable(item)
#endif
        }
#if os(tvOS)
        .buttonStyle(.card)
#else
        .buttonStyle(.plain)
#endif
        .accessibility(label: Text(item.itemTitle))
    }
}

struct Poster_Previews: PreviewProvider {
    @State static var show = false
    static var previews: some View {
        Poster(item: .previewContent, addedItemConfirmation: $show)
    }
}

struct PosterPlaceholder: View {
    var title: String
    let type: MediaType
    var body: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            VStack {
                Text(title)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .padding()
                Image(systemName: type == .tvShow ? "tv" : "film")
                    .font(.title)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
        .frame(width: DrawingConstants.posterWidth,
               height: DrawingConstants.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                    style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let posterWidth: CGFloat = 260
    static let posterHeight: CGFloat = 380
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
#else
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
    static let shadowRadius: CGFloat = 2
#endif
}
