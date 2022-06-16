//
//  SearchItemView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/05/22.
//

import SwiftUI

struct SearchItemView: View {
    let content: ItemContent?
    @Binding var showConfirmation: Bool
    var body: some View {
        if let content {
            NavigationLink(destination: ContentDetailsView(title: content.itemTitle,
                                                           id: content.id,
                                                           type: content.media),
                           label: {
                HStack {
                    if content.media == .person {
                        AsyncImage(url: content.itemImage,
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
                        AsyncImage(url: content.itemImage,
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
                            Text(content.itemTitle)
                                .lineLimit(DrawingConstants.textLimit)
                        }
                        HStack {
                            Text(content.media.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .modifier(ItemContentContextMenu(item: content, showConfirmation: $showConfirmation))
                .accessibilityElement(children: .combine)
            })
        }
    }
}

struct SearchItemView_Previews: PreviewProvider {
    @State private static var show: Bool = false
    static var previews: some View {
        SearchItemView(content: ItemContent.previewContent, showConfirmation: $show)
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
