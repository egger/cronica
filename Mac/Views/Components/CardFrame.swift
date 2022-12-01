//
//  ItemContentCardView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentCardView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    private let context = PersistenceController.shared
    @State private var isInWatchlist: Bool = false
    @State private var isWatched = false
    var body: some View {
        NavigationLink(value: item) {
            VStack {
                WebImage(url: item.cardImageMedium)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.thickMaterial)
                            VStack {
                                Text(item.itemTitle)
                                    .font(.callout)
                                    .lineLimit(DrawingConstants.titleLineLimit)
                                    .padding(.bottom)
                                Image(systemName: "film")
                            }
                            .padding()
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
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height:DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.imageShadow)
                    .draggable(item)
                    .modifier(
                        ItemContentContextMenu(item: item,
                                               showConfirmation: $showConfirmation,
                                               isInWatchlist: $isInWatchlist,
                                               isWatched: $isWatched)
                    )
                HStack {
                    Text(item.itemTitle)
                        .font(.caption)
                        .lineLimit(DrawingConstants.titleLineLimit)
                    Spacer()
                }
                .frame(width: DrawingConstants.imageWidth)
            }
            .task {
                withAnimation {
                    isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                    if isInWatchlist && !isWatched {
                        isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                    }
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let titleLineLimit: Int = 1
}

struct ItemContentCardView_Previews: PreviewProvider {
    @State private static var showConfirmation = false
    static var previews: some View {
        ItemContentCardView(item: ItemContent.previewContent, showConfirmation: $showConfirmation)
    }
}
