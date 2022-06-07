//
//  ItemContentFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/06/22.
//

import SwiftUI

struct ItemContentFrameView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    var body: some View {
        VStack {
            AsyncImage(url: item.cardImageMedium,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                } else if phase.error != nil {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            Text(item.itemTitle)
                                .font(.callout)
                                .lineLimit(1)
                                .padding(.bottom)
                            Image(systemName: "film")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                } else {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            ProgressView()
                                .padding(.bottom)
                            Image(systemName: "film")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth :  DrawingConstants.imageWidth,
                    height: UIDevice.isIPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius,
                                                   style: .continuous))
            .modifier(ItemContentContextMenu(item: item, showConfirmation: $showConfirmation))
            .shadow(radius: 4)
            HStack {
                Text(item.itemTitle)
                    .font(.caption)
                    .lineLimit(DrawingConstants.titleLineLimit)
                Spacer()
            }
            .frame(width: UIDevice.isIPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth)
        }
    }
}

struct ItemContentFrameView_Previews: PreviewProvider {
    @State private static var show: Bool = false
    static var previews: some View {
        ItemContentFrameView(item: ItemContent.previewContent,
                             showConfirmation: $show)
    }
}


private struct DrawingConstants {
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 240
    static let padImageHeight: CGFloat = 140
    static let padImageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
}
