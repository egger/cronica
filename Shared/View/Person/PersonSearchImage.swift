//
//  PersonSearchImage.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 20/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

/// A rectangular shape for displaying Person images in Search, it is currently used
/// for displaying people in Search for macOS. This is a simpler view from the Cast List.
struct PersonSearchImage: View {
    let item: ItemContent
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.itemImage, options: .highPriority)
                .resizable()
                .placeholder { placeholder }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.zero)
#if os(macOS) || os(iOS)
                .contextMenu { ShareLink(item: item.itemSearchURL) }
#endif
        }
    }
    
    private var placeholder: some View {
        ZStack {
            Rectangle().fill(.gray.gradient)
            Image(systemName: "person")
                .font(.title)
                .foregroundColor(.secondary)
        }
        .frame(width: DrawingConstants.posterWidth,
               height: DrawingConstants.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                    style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
        .padding(.zero)
    }
}

private struct DrawingConstants {
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2.5
}


struct PosterSearchItem: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    var body: some View {
        if item.media == .person {
            PersonSearchImage(item: item)
                .buttonStyle(.plain)
        } else {
            Poster(item: item, addedItemConfirmation: $showConfirmation)
                .buttonStyle(.plain)
        }
    }
}
