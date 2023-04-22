//
//  ItemContentRow.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentRow: View {
    let item: ItemContent
    @State private var isItemAdded = false
    @State private var isWatched = false
    @State private var showConfirmation = false
    var body: some View {
        HStack {
            WebImage(url: item.cardImageSmall)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: item.itemContentMedia == .movie ? "film" : "tv")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            
            VStack(alignment: .leading) {
                Text(item.itemTitle)
                Text(item.itemContentMedia.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if isItemAdded {
                Spacer()
                VStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                    Spacer()
                }
                .padding(.trailing)
            }
        }
        .task {
            isItemAdded = PersistenceController.shared.isItemSaved(id: item.id, type: item.itemContentMedia)
            if isItemAdded {
                isWatched = PersistenceController.shared.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
            }
        }
        .itemContentContextMenu(item: item,
                                isWatched: $isWatched,
                                showConfirmation: $showConfirmation,
                                isInWatchlist: $isItemAdded)
    }
}

struct ItemContentRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentRow(item: .previewContent)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
