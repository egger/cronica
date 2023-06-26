//
//  UpNextItem.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct UpNextItem: View {
    let item: UpNextEpisode
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        ZStack {
            WebImage(url: item.episode.itemImageLarge ?? item.backupImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: "sparkles.tv")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: settings.isCompactUI ? DrawingConstants.compactImageWidth : DrawingConstants.imageWidth,
                       height: settings.isCompactUI ? DrawingConstants.compactImageHeight : DrawingConstants.imageHeight)
                .transition(.opacity)
            
            VStack(alignment: .leading) {
                Spacer()
                ZStack(alignment: .bottom) {
                    Color.black.opacity(0.4)
                        .frame(height: 50)
                        .mask {
                            LinearGradient(colors: [Color.black,
                                                    Color.black.opacity(0.924),
                                                    Color.black.opacity(0.707),
                                                    Color.black.opacity(0.383),
                                                    Color.black.opacity(0)],
                                           startPoint: .bottom,
                                           endPoint: .top)
                        }
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 70)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [Color.black.opacity(0),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.924),
                                                        Color.black],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .frame(height: 50)
                                Rectangle()
                            }
                        }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.showTitle)
                                .font(.callout)
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text("E\(item.episode.itemEpisodeNumber), S\(item.episode.itemSeasonNumber)")
                                .font(.caption)
                                .textCase(.uppercase)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 8)
                    .padding(.leading)
                }
            }
        }
        .frame(width: settings.isCompactUI ? DrawingConstants.compactImageWidth : DrawingConstants.imageWidth,
               height: settings.isCompactUI ? DrawingConstants.compactImageHeight : DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(radius: 2.5)
        .accessibilityLabel("Episode: \(item.episode.itemEpisodeNumber), of the show: \(item.showTitle).")
        .accessibilityAddTraits(.isButton)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 280
    static let imageHeight: CGFloat = 160
    static let compactImageWidth: CGFloat = 200
    static let compactImageHeight: CGFloat = 120
    static let imageRadius: CGFloat = 16
    static let titleLineLimit: Int = 1
    static let imageShadow: CGFloat = 2.5
}
