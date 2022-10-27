//
//  RectangularItemContentView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct RectangularItemContentView: View {
    let item: ItemContent
    private var image: URL?
    private var type: MediaType
    @State private var isInWatchlist = false
    @State private var isWatched = false
    private let context = PersistenceController.shared
    init(item: ItemContent) {
        self.item = item
        if item.media == .person {
            self.image = item.castImage
        } else {
            self.image = item.posterImageMedium
        }
        self.type = item.media
    }
    var body: some View {
        WebImage(url: image)
            .resizable()
            .placeholder {
                VStack {
                    Text(item.itemTitle)
                        .lineLimit(1)
                        .padding(.bottom)
                    if type == .person {
                        Image(systemName: "person")
                    } else {
                        Image(systemName: "film")
                    }
                }
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .overlay {
                    if type == .person {
                        VStack {
                            Spacer()
                            HStack {
                                Text(item.itemTitle)
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .padding(.leading, 6)
                                Spacer()
                            }
                        }
                        .padding(.bottom)
                        .background {
                            Color.black.opacity(0.8)
                                .frame(height: 60)
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
//                            ZStack {
//                                Color.black.opacity(0.2)
//                                    .frame(height: 40)
//                                    .mask {
//                                        LinearGradient(colors: [Color.black.opacity(0),
//                                                                Color.black.opacity(0.383),
//                                                                Color.black.opacity(0.707),
//                                                                Color.black.opacity(0.924),
//                                                                Color.black],
//                                                       startPoint: .top,
//                                                       endPoint: .bottom)
//                                    }
//                                Rectangle()
//                                    .fill(.ultraThinMaterial)
//                                    .frame(height: 80)
//                                    .mask {
//                                        VStack(spacing: 0) {
//                                            LinearGradient(colors: [Color.black.opacity(0),
//                                                                    Color.black.opacity(0.383),
//                                                                    Color.black.opacity(0.707),
//                                                                    Color.black.opacity(0.924),
//                                                                    Color.black],
//                                                           startPoint: .top,
//                                                           endPoint: .bottom)
//                                            .frame(height: 60)
//                                            Rectangle()
//                                        }
//                                    }
//                            }
                        }
                    } else {
                        if isInWatchlist {
                            VStack {
                                Spacer()
                                HStack {
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
                        }
                    }
                }
                .aspectRatio(contentMode: .fill)
                .transition(.opacity)
                .frame(width: DrawingConstants.posterWidth,
                       height: DrawingConstants.posterHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.posterRadius,
                                            style: .continuous))
                .padding(.zero)
                .task {
                    if type != .person {
                        withAnimation {
                            isInWatchlist = context.isItemSaved(id: item.id, type: item.itemContentMedia)
                            if isInWatchlist && !isWatched {
                                isWatched = context.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
                            }
                        }
                    }
                }
            }
    }
}

struct RectangularItemContentView_Previews: PreviewProvider {
    static var previews: some View {
        RectangularItemContentView(item: ItemContent.previewContent)
    }
}




struct PosterViewn: View {
    let item: ItemContent
    
    @State private var isInWatchlist = false
    @State private var isWatched = false
    @Binding var addedItemConfirmation: Bool
    var body: some View {
        NavigationLink(value: item) {
            WebImage(url: item.posterImageMedium)
                
                
        }
        .ignoresSafeArea(.all)
        .buttonStyle(.card)
    }
}



private struct DrawingConstants {
    static let posterWidth: CGFloat = 220
    static let posterHeight: CGFloat = 320
    static let posterRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 2
}
