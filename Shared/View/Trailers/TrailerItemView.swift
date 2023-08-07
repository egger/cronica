//
//  TrailerItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 20/08/22.
//

import SwiftUI
import SDWebImageSwiftUI
import YouTubePlayerKit

#if os(iOS) || os(macOS)
struct TrailerItemView: View {
    private let trailer: VideoItem
    private let player: YouTubePlayer
    @State private var isLoading = false
    @AppStorage("openInYouTube") private var openInYouTube = false
    init(trailer: VideoItem) {
        self.trailer = trailer
        self.player = YouTubePlayer(
            source: .video(id: trailer.videoID),
            configuration: .init(
                automaticallyAdjustsContentInsets: true,
                allowsPictureInPictureMediaPlayback: false,
                fullscreenMode: .system,
                autoPlay: false,
                showControls: true,
                showFullscreenButton: true,
                useModestBranding: true,
                playInline: false,
                showRelatedVideos: false
            )
        )
    }
    var body: some View {
        ZStack {
            YouTubePlayerView(player)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .opacity(0)
            VStack {
                WebImage(url: trailer.thumbnail)
                    .resizable()
                    .placeholder {
                        placeholder
                    }
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .overlay { overlay }
                    .contextMenu {
                        if let url = trailer.url {
                            ShareLink(item: url)
#if os(iOS)
                            Button("Open in YouTube") {
                                UIApplication.shared.open(url)
                            }
#endif
                        }
                    }
                    .applyHoverEffect()
                    .shadow(radius: 2.5)
                HStack {
                    Text(trailer.title)
                        .lineLimit(DrawingConstants.lineLimits)
                        .padding([.trailing, .bottom])
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .frame(width: DrawingConstants.imageWidth)
        }
        .frame(width: DrawingConstants.imageWidth)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(trailer.title)
        .onTapGesture(perform: openVideo)
    }
    
    private func openVideo() {
        self.isLoading = true
#if os(iOS)
        if UIDevice.isIPhone {
            player.play()
        } else {
            if let url = trailer.url {
                UIApplication.shared.open(url)
            }
        }
#else
        player.play()
#endif
    }
    
    private var placeholder: some View {
        ZStack {
            Color.secondary
            Image(systemName: "play.fill")
                .foregroundColor(.white)
                .imageScale(.medium)
        }
        .transition(.opacity)
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                    style: .continuous))
    }
    
    private var overlay: some View {
        ZStack {
            Color.black.opacity(DrawingConstants.overlayOpacity)
#if os(iOS)
            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(width: DrawingConstants.overlayWidth,
                           height: DrawingConstants.overlayHeight,
                           alignment: .center)
                    .padding()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                            withAnimation { self.isLoading = false }
                        }
                    }
            } else {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: DrawingConstants.overlayWidth,
                           height: DrawingConstants.overlayHeight,
                           alignment: .center)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .secondary)
                    .scaledToFit()
                    .imageScale(.medium)
                    .padding()
            }
#else
            Image(systemName: "play.circle.fill")
                .resizable()
                .frame(width: DrawingConstants.overlayWidth,
                       height: DrawingConstants.overlayHeight,
                       alignment: .center)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .secondary)
                .scaledToFit()
                .imageScale(.medium)
                .padding()
#endif
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                    style: .continuous))
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 12
    static let imageShadow: CGFloat = 2.5
    static let imageWidth: CGFloat = 220
    static let imageHeight: CGFloat = 120
    static let overlayOpacity: Double = 0.2
    static let overlayWidth: CGFloat = 50
    static let overlayHeight: CGFloat = 50
    static let lineLimits: Int = 1
}
#endif
