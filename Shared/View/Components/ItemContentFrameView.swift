//
//  ItemContentFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/06/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentFrameView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    private let context = PersistenceController.shared
    @State private var isInWatchlist: Bool = false
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
                        .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
                               height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius, style: .continuous))
                    }
                    .overlay {
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Image(systemName: "square.stack.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding()
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
                    .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
                           height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius,
                                                style: .continuous))
                    .draggable(item)
                    .modifier(ItemContentContextMenu(item: item,
                                                     showConfirmation: $showConfirmation,
                                                     isInWatchlist: $isInWatchlist))
                    .shadow(radius: DrawingConstants.imageShadow)
                HStack {
                    Text(item.itemTitle)
                        .font(.caption)
                        .lineLimit(DrawingConstants.titleLineLimit)
                    Spacer()
                }
                .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth)
            }
            .hoverEffect(.lift)
            .task {
                withAnimation {
                    isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                }
            }
        }
    }
}

struct ItemContentFrameView_Previews: PreviewProvider {
    @State private static var show = false
    static var previews: some View {
        ItemContentFrameView(item: ItemContent.previewContent,
                             showConfirmation: $show)
    }
}


private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let imageShadow: CGFloat = 2.5
    static let padImageWidth: CGFloat = 240
    static let padImageHeight: CGFloat = 140
    static let padImageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
}
