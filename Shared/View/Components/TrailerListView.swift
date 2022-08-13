//
//  TrailerListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrailerListView: View {
    var trailers: [VideoItem]?
    @State var selectedItem: VideoItem? = nil
    var body: some View {
        if let trailers {
            VStack {
                Divider().padding(.horizontal)
                HStack {
                    Text("Trailers")
                        .fontWeight(.semibold)
                        .padding([.horizontal, .top])
                    Spacer()
                }
                .unredacted()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(trailers) { trailer in
                            VStack {
                                Button(action: {
                                    HapticManager.shared.softHaptic()
                                    selectedItem = trailer
                                }, label: {
                                    if let thumbnail = trailer.thumbnail {
                                        ZStack {
                                            WebImage(url: thumbnail)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .transition(.opacity)
                                                .frame(width: DrawingConstants.imageWidth,
                                                       height: DrawingConstants.imageHeight)
                                            Color.black.opacity(0.1)
                                            Image(systemName: "play.circle.fill")
                                                .resizable()
                                                .frame(width: 40, height: 40, alignment: .center)
                                                .symbolRenderingMode(.palette)
                                                .foregroundStyle(.white, .secondary)
                                                .scaledToFit()
                                                .imageScale(.medium)
                                                .padding()
                                        }

                                    } else {
                                        ZStack {
                                            Color.secondary
                                            Image(systemName: "play.fill")
                                                .foregroundColor(.white)
                                                .imageScale(.medium)
                                        }
                                        .frame(width: DrawingConstants.imageWidth,
                                               height: DrawingConstants.imageHeight)
                                    }
                                })
                                .buttonStyle(.plain)
                                .frame(width: DrawingConstants.imageWidth,
                                       height: DrawingConstants.imageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                                .contextMenu {
                                    if let url = trailer.url {
                                        ShareLink(item: url)
                                    }
                                }
                                .shadow(radius: 2.5)
                                HStack {
                                    Text(trailer.title)
                                        .lineLimit(1)
                                        .padding([.horizontal, .bottom])
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel(trailer.title)
                            .frame(width: DrawingConstants.imageWidth)
                            .padding(.horizontal, 4)
                            .padding(.leading, trailer.id == self.trailers?.first!.id ? 16 : 0)
                            .padding(.trailing, trailer.id == self.trailers?.last!.id ? 16 : 0)
                        }
                    }
                    .padding(.top, 8)
                }
                Divider().padding(.horizontal)
            }
            .sheet(item: $selectedItem) { item in
                if let url = item.url {
                    SFSafariViewWrapper(url: url)
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 220
    static let imageHeight: CGFloat = 120
}
