//
//  PersonItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 05/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonItemView: View {
    let item: PersonItem
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                WebImage(url: item.image)
                    .placeholder {
                        VStack {
                            ProgressView()
                        }
                        .backgroundStyle(.secondary)
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .clipShape(Circle())
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Spacer()
                    Text(item.personName)
                        .lineLimit(DrawingConstants.textLimit)
                    Spacer()
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 50
    static let imageHeight: CGFloat = 50
    static let textLimit: Int = 1
}
