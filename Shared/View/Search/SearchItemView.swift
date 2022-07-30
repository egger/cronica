//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI

struct SearchItemView: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    var body: some View {
        if item.media == .person {
            NavigationLink(value: item) {
                SearchItem(item: item)
                    .contextMenu {
                        ShareLink(item: item.itemSearchURL)
                    }
            }
        } else {
            NavigationLink(value: item) {
                SearchItem(item: item)
                    .modifier(ItemContentContextMenu(item: item, showConfirmation: $showConfirmation))
            }
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    @State private static var show: Bool = false
    static var previews: some View {
        SearchItemView(item: ItemContent.previewContent, showConfirmation: $show)
    }
}

struct SearchItem: View {
    let item: ItemContent
    var body: some View {
        HStack {
            if item.media == .person {
                AsyncImage(url: item.itemImage,
                           transaction: Transaction(animation: .easeInOut)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity)
                    } else if phase.error != nil {
                        ZStack {
                            ProgressView()
                        }.background(.secondary)
                    } else {
                        ZStack {
                            Color.secondary
                            Image(systemName: "person")
                        }
                    }
                }
                .frame(width: DrawingConstants.personImageWidth,
                       height: DrawingConstants.personImageHeight)
                .clipShape(Circle())
            } else {
                AsyncImage(url: item.itemImage,
                           transaction: Transaction(animation: .easeInOut)) { phase in
                    if let image = phase.image {
                        ZStack {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .transition(.opacity)
                        }
                    } else if phase.error != nil {
                        ZStack {
                            Color.secondary
                            ProgressView()
                        }
                    } else {
                        ZStack {
                            Color.secondary
                            Image(systemName: "film")
                        }
                    }
                }
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(item.itemTitle)
                        .lineLimit(DrawingConstants.textLimit)
                }
                HStack {
                    Text(item.media.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
    static let personImageWidth: CGFloat = 60
    static let personImageHeight: CGFloat = 60
}
