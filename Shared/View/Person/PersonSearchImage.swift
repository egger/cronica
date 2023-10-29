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
    let item: SearchItemContent
    @FocusState var isStackFocused: Bool
    var body: some View {
        VStack(alignment: .leading) {
            image
#if os(tvOS)
            HStack {
                Text(item.itemTitle)
                    .padding(.top, 4)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundStyle(isStackFocused ? .primary : .secondary)
                    .frame(maxWidth: DrawingConstants.posterWidth)
                Spacer()
            }
            Spacer()
#endif
        }
#if os(tvOS)
        .focused($isStackFocused)
        .buttonStyle(.card)
#endif
    }
    
    private var image: some View {
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
#elseif os(tvOS)
                .buttonStyle(.card)
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
#if os(tvOS)
    static let posterWidth: CGFloat = 260
    static let posterHeight: CGFloat = 380
#else
    static let posterWidth: CGFloat = 160
    static let posterHeight: CGFloat = 240
#endif
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2.5
}

struct PosterSearchItem: View {
    let item: SearchItemContent
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        if item.media == .person {
            PersonSearchImage(item: item)
                .buttonStyle(.plain)
        } else {
            SearchContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
                .buttonStyle(.plain)
        }
    }
}
