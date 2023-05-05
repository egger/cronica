//
//  ItemContentFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/06/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CardFrame: View {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    private let context = PersistenceController.shared
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @State private var showNote = false
    var body: some View {
        NavigationLink(value: item) {
            VStack {
                WebImage(url: item.cardImageMedium)
                    .resizable()
                    .placeholder {
                        ZStack {
                            Rectangle().fill(.gray.gradient)
                            VStack {
                                Text(item.itemTitle)
                                    .font(.caption)
                                    .foregroundColor(DrawingConstants.placeholderForegroundColor)
                                    .lineLimit(1)
                                    .padding()
                                Image(systemName: item.itemContentMedia == .tvShow ? "tv" : "film")
                                    .foregroundColor(DrawingConstants.placeholderForegroundColor)
                            }
                            .padding()
                        }
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                    }
                    .overlay {
#if os(tvOS)
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
                                    Text(item.itemTitle)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .padding()
                                    Spacer()
                                    if isWatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding()
                                    } else {
                                        Image(systemName: "square.stack.fill")
                                            .foregroundColor(.white.opacity(0.8))
                                            .padding()
                                    }
                                }
                                .background {
                                    Color.black.opacity(0.5)
                                        .mask {
                                            LinearGradient(colors:
                                                            [Color.black,
                                                             Color.black.opacity(0.924),
                                                             Color.black.opacity(0.707),
                                                             Color.black.opacity(0.383),
                                                             Color.black.opacity(0)],
                                                           startPoint: .bottom,
                                                           endPoint: .top)
                                        }
                                }
                            }
                        } else {
                            VStack {
                                Spacer()
                                HStack {
                                    Text(item.itemTitle)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .padding()
                                    Spacer()
                                }
                                .background {
                                    Color.black.opacity(0.5)
                                        .mask {
                                            LinearGradient(colors:
                                                            [Color.black,
                                                             Color.black.opacity(0.924),
                                                             Color.black.opacity(0.707),
                                                             Color.black.opacity(0.383),
                                                             Color.black.opacity(0)],
                                                           startPoint: .bottom,
                                                           endPoint: .top)
                                        }
                                }
                            }
                        }
#else
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    if isWatched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(DrawingConstants.placeholderForegroundColor)
                                            .padding()
                                    } else {
                                        Image(systemName: "square.stack.fill")
                                            .foregroundColor(DrawingConstants.placeholderForegroundColor)
                                            .padding()
                                    }
                                }
                                .background {
                                    if item.cardImageMedium != nil {
                                        Color.black.opacity(0.5)
                                            .mask {
                                                LinearGradient(colors:
                                                                [Color.black,
                                                                 Color.black.opacity(0.924),
                                                                 Color.black.opacity(0.707),
                                                                 Color.black.opacity(0.383),
                                                                 Color.black.opacity(0)],
                                                               startPoint: .bottom,
                                                               endPoint: .top)
                                            }
                                    }
                                }
                            }
                        }
#endif
                    }
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .shadow(radius: DrawingConstants.imageShadow)
                    .applyHoverEffect()
                    .itemContentContextMenu(item: item,
                                            isWatched: $isWatched,
                                            showConfirmation: $showConfirmation,
                                            isInWatchlist: $isInWatchlist,
                                            showNote: $showNote)
#if os(iOS) || os(macOS)
                    .draggable(item)
#endif
#if os(iOS) || os(macOS)
                HStack {
                    Text(item.itemTitle)
                        .font(.caption)
                        .lineLimit(DrawingConstants.titleLineLimit)
                        .accessibilityHidden(true)
                    Spacer()
                }
                .frame(width: DrawingConstants.imageWidth)
#endif
            }
            .task {
                withAnimation {
                    isInWatchlist = context.isItemSaved(id: item.itemNotificationID)
                    if isInWatchlist && !isWatched {
                        isWatched = context.isMarkedAsWatched(id: item.itemNotificationID)
                    } 
                }
            }
            .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                NavigationStack {
                    ReviewView(id: item.itemNotificationID, showView: $showNote)
                }
                .presentationDetents([.medium, .large])
#if os(macOS)
                .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
                .appTheme()
                .appTint()
#endif
#endif
            }
        }
        .accessibilityLabel(Text(item.itemTitle))
#if os(tvOS)
        .buttonStyle(.card)
#endif
    }
}

struct CardFrame_Previews: PreviewProvider {
    static var previews: some View {
        CardFrame(item: .example, showConfirmation: .constant(false))
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let imageWidth: CGFloat = 240
    static let imageHeight: CGFloat = 140
    static let imageRadius: CGFloat = 12
    static let titleLineLimit: Int = 1
#elseif os(tvOS)
    static let imageWidth: CGFloat = 440
    static let imageHeight: CGFloat = 240
    static let imageRadius: CGFloat = 8
    static let titleLineLimit: Int = 1
#elseif os(iOS)
    static let imageWidth: CGFloat = UIDevice.isIPad ? 240 : 160
    static let imageHeight: CGFloat = UIDevice.isIPad ? 140 : 100
    static let imageRadius: CGFloat = UIDevice.isIPad ? 12 : 8
    static let titleLineLimit: Int = 1
#endif
    static let imageShadow: CGFloat = 2.5
    static let placeholderForegroundColor: Color = .white.opacity(0.8)
}
