//
//  CoverImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI

private struct CoverImageView1: View {
    @EnvironmentObject var store: SettingsStore
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
    @State private var isPad: Bool = UIDevice.isIPad
    @Binding var animateGesture: Bool
    let image: URL?
    let title: String
    let isAdult: Bool
    let glanceInfo: String?
    var body: some View {
        VStack {
            ZStack {
                HeroImage(url: image, title: title, blurImage: isAdult)
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    if store.gesture == .favorite {
                        Image(systemName: isFavorite ? "heart.fill" : "heart.slash.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    } else {
                        Image(systemName: isWatched ? "checkmark.circle" : "minus.circle.fill")
                            .symbolRenderingMode(.monochrome)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    }
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .frame(width: isPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                   height: isPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
            .cornerRadius(isPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius)
            .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                    radius: DrawingConstants.shadowRadius)
            .padding([.top, .bottom])
            .accessibilityElement(children: .combine)
            .accessibility(hidden: true)
            
            if let glanceInfo {
                Text(glanceInfo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct DrawingConstants {
    static let shadowOpacity: Double = 0.2
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}

struct CoverImageView: View {
    let item: ItemContent?
    let titlePlaceholder: String
    @EnvironmentObject var settings: SettingsStore
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
    @Binding var animateGesture: Bool
    var body: some View {
        ViewThatFits {
            image
                .frame(width: DrawingConstants.padImageWidth, height: DrawingConstants.padImageHeight)
                .padding([.top, .bottom])
            image
                .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
                .padding([.top, .bottom])
        }
    }
    
    var image: some View {
        VStack {
            ZStack {
                HeroImage(url: item?.cardImageLarge, title: titlePlaceholder, blurImage: item?.itemIsAdult ?? false)
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    if settings.gesture == .favorite {
                        Image(systemName: isFavorite ? "heart.fill" : "heart.slash.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    } else {
                        Image(systemName: isWatched ? "checkmark.circle" : "minus.circle.fill")
                            .symbolRenderingMode(.monochrome)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    }
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .cornerRadius(UIDevice.isIPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius)
            .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                    radius: DrawingConstants.shadowRadius)
            .padding([.top, .bottom])
            .accessibilityElement(children: .combine)
            .accessibility(hidden: true)
            
            if let info = item?.itemInfo {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
