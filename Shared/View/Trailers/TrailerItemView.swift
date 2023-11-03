//
//  TrailerItemView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 20/08/22.
//
#if os(iOS) || os(macOS)
import SwiftUI
import SDWebImageSwiftUI
#if os(iOS)
import YouTubePlayerKit
#endif

struct TrailerItemView: View {
    private let trailer: VideoItem
#if os(iOS)
    private let player: YouTubePlayer
#endif
    @State private var isLoading = false
    @State private var showWebPlayer = false
    @AppStorage("openInYouTube") private var openInYouTube = false
    init(trailer: VideoItem) {
        self.trailer = trailer
#if os(iOS)
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
#endif
    }
    var body: some View {
        ZStack {
#if os(iOS)
            YouTubePlayerView(player)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .opacity(0)
#endif
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
#if os(iOS)
        .fullScreenCover(isPresented: $showWebPlayer) {
            if let url = trailer.url {
                SFSafariViewWrapper(url: url)
            }
        }
#endif
    }
    
    private func openVideo() {
#if os(iOS)
        if UIDevice.isIPhone {
            if openInYouTube {
                if let url = trailer.url {
                    UIApplication.shared.open(url)
                }
            } else {
                self.isLoading = true
                player.play()
            }
        } else {
            if openInYouTube {
                if let url = trailer.url {
                    UIApplication.shared.open(url)
                }
            } else {
                showWebPlayer = true
            }
        }
#elseif os(macOS)
        if let url = trailer.url {
            NSWorkspace.shared.open(url)
        }
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
    static let imageRadius: CGFloat = 8
    static let imageShadow: CGFloat = 2.5
    static let imageWidth: CGFloat = 220
    static let imageHeight: CGFloat = 120
    static let overlayOpacity: Double = 0.2
    static let overlayWidth: CGFloat = 50
    static let overlayHeight: CGFloat = 50
    static let lineLimits: Int = 1
}
#endif
