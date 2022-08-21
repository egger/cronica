//
//  CoverImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//
import SwiftUI

struct CoverImageView: View {
    @StateObject private var store = SettingsStore()
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var isPad: Bool = UIDevice.isIPad
    @State private var animateGesture: Bool = false
    let title: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        VStack {
            HeroImage(url: viewModel.content?.cardImageLarge,
                      title: title,
                      blurImage: viewModel.content?.itemIsAdult ?? false)
            .overlay {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    if store.gesture == .favorite {
                        Image(systemName: viewModel.isFavorite ? "heart.slash.fill" : "heart.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    } else {
                        Image(systemName: viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle")
                            .symbolRenderingMode(.monochrome)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    }
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                   height: (horizontalSizeClass == .compact) ? DrawingConstants.imageHeight : DrawingConstants.padImageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: DrawingConstants.shadowRadius)
            .padding([.top, .bottom])
            .accessibilityElement(children: .combine)
            .accessibility(hidden: true)
            .onTapGesture(count: 2) {
                withAnimation {
                    animateGesture.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        animateGesture = false
                    }
                    if store.gesture == .favorite {
                        viewModel.update(markAsFavorite: !viewModel.isFavorite)
                    } else {
                        viewModel.update(markAsWatched: !viewModel.isWatched)
                    }
                }
            }
            .hoverEffect(.highlight)
            
            if let info = viewModel.content?.itemInfo {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}
