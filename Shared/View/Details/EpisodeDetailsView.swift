//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    let item: Episode
    var body: some View {
        ScrollView {
            VStack {
                HeroImage(url: item.itemImageLarge, title: item.itemTitle)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .cornerRadius(DrawingConstants.imageRadius)
                GroupBox {
                    Text(item.itemAbout)
                        .padding([.top, .bottom], 4)
                } label: {
                    Label("About", systemImage: "tv")
                }
                .padding([.horizontal, .bottom])
            }
            .navigationTitle(item.itemTitle)
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let padImageWidth: CGFloat = 660
    static let padImage: CGFloat = 510
    static let imageRadius: CGFloat = 8
}
