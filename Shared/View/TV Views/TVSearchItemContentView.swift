//
//  SearchItemContentView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TVSearchItemContentView: View {
    let item: ItemContent
    private var image: URL?
    @State private var isInWatchlist = false
    @State private var isWatched = false
    private let context = PersistenceController.shared
    init(item: ItemContent) {
        self.item = item
    }
    var body: some View {
        WebImage(url: item.itemImage)
            .resizable()
            .placeholder {
                VStack {
                    Text(item.itemTitle)
                        .lineLimit(1)
                        .padding(.bottom)
                    if item.media == .person {
                        Image(systemName: "person")
                    } else {
                        Image(systemName: "film")
                    }
                }
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
            }
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
            .frame(width: DrawingConstants.posterWidth,
                   height: DrawingConstants.posterHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                        style: .continuous))
            .aspectRatio(contentMode: .fill)
            .transition(.opacity)
            .padding(.zero)
            .task {
                if item.media != .person {
                    withAnimation {
                        isInWatchlist = context.isItemSaved(id: item.itemNotificationID)
                        if isInWatchlist && !isWatched {
                            isWatched = context.isMarkedAsWatched(id: item.itemNotificationID)
                        }
                    }
                }
            }
    }
}

struct SearchItemContentView_Previews: PreviewProvider {
    static var previews: some View {
        TVSearchItemContentView(item: ItemContent.previewContent)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 220
    static let posterHeight: CGFloat = 320
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}
