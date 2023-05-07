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
    @State private var canReview = false
    @State private var showNote = false
    @Binding var addedItemConfirmation: Bool
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        NavigationLink(value: item) {
            if settings.isCompactUI {
                compact
            } else {
                image
            }
        }
#if os(tvOS)
        .buttonStyle(.card)
#else
        .buttonStyle(.plain)
#endif
        .accessibility(label: Text(item.itemTitle))
    }
    
    private var image: some View {
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
            .frame(width: settings.isCompactUI ? DrawingConstants.compactPosterWidth : DrawingConstants.posterWidth,
                   height: settings.isCompactUI ? DrawingConstants.compactPosterHeight : DrawingConstants.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: settings.isCompactUI ? DrawingConstants.compactPosterRadius : DrawingConstants.posterRadius,
                                        style: .continuous))
            .shadow(radius: DrawingConstants.shadowRadius)
            .padding(.zero)
            .applyHoverEffect()
            .itemContentContextMenu(item: item,
                                    isWatched: $isWatched,
                                    showConfirmation: $addedItemConfirmation,
                                    isInWatchlist: $isInWatchlist,
                                    showNote: $showNote)
            .task {
                withAnimation {
                    isInWatchlist = context.isItemSaved(id: item.itemNotificationID)
                    if isInWatchlist && !isWatched {
                        isWatched = context.isMarkedAsWatched(id: item.itemNotificationID)
                        canReview = true
                    } else {
                        if canReview { canReview = false }
                    }
                }
            }
            .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                NavigationStack {
                    ReviewView(id: item.itemNotificationID, showView: $showNote)
                }
                .presentationDetents([.medium, .large])
#if os(macOS)
                .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                .appTheme()
                .appTint()
#endif
#endif
            }
#if os(iOS) || os(macOS)
            .draggable(item)
#endif
    }
    
    private var compact: some View {
        VStack(alignment: .leading) {
            image
            HStack {
                Text(item.itemTitle)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .accessibilityHidden(true)
                Spacer()
            }
            Spacer()
        }
        .frame(maxWidth: DrawingConstants.compactPosterWidth)
    }
}

struct Poster_Previews: PreviewProvider {
    static var previews: some View {
        Poster(item: .example, addedItemConfirmation: .constant(false))
    }
}

private struct DrawingConstants {
#if os(tvOS)
    static let posterWidth: CGFloat = 260
    static let posterHeight: CGFloat = 380
    static let posterRadius: CGFloat = 12
#else
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 8
#endif
    static let compactPosterWidth: CGFloat = 80
    static let compactPosterRadius: CGFloat = 4
    static let compactPosterHeight: CGFloat = 140
    static let shadowRadius: CGFloat = 2
}
