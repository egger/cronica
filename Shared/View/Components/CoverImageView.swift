//
//  CoverImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//
import SwiftUI
import SDWebImageSwiftUI

struct CoverImageView: View {
    @StateObject private var store = SettingsStore()
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var isPad: Bool = UIDevice.isIPad
    @State private var animateGesture: Bool = false
    @State private var isFavorite = false
    @State private var isWatched = false
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
                        Image(systemName: isFavorite ? "heart.slash.fill" : "heart.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                            .scaleEffect(animateGesture ? 1.1 : 1)
                    } else {
                        Image(systemName: isWatched ? "minus.circle.fill" : "checkmark.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                            .foregroundColor(isWatched ? Color.red : Color.green)
                            .scaleEffect(animateGesture ? 1.1 : 1)
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
                if store.gesture == .favorite {
                    viewModel.updateMarkAs(markAsFavorite: !viewModel.isFavorite)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        isFavorite.toggle()
                    }
                } else {
                    viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        isWatched.toggle()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        animateGesture = false
                    }
                }
            }
            .task {
                isFavorite = viewModel.isFavorite
                isWatched = viewModel.isWatched
            }
            
            if let info = viewModel.content?.itemInfo {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CoverImagePlaceholder: View {
    let title: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        ZStack {
#if os(watchOS)
            Rectangle().fill(.secondary)
#else
            Rectangle().fill(.thickMaterial)
#endif
            VStack {
                Text(title)
                    .lineLimit(1)
                    .padding()
                Image(systemName: "film")
            }
            .padding()
            .foregroundColor(.secondary)
        }
        .frame(width: (horizontalSizeClass == .regular) ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
               height: (horizontalSizeClass == .compact) ? DrawingConstants.imageHeight : DrawingConstants.padImageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
        .shadow(radius: DrawingConstants.shadowRadius)
        .padding([.top, .bottom])
        .accessibilityElement(children: .combine)
        .accessibility(hidden: true)
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
