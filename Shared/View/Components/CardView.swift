//
//  CardView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//  swiftlint:disable trailing_whitespace

import SwiftUI
import SDWebImageSwiftUI

struct CardView: View {
    let item: WatchlistItem
    var body: some View {
        ZStack {
            Rectangle().fill(.ultraThinMaterial)
            Color.black.opacity(0.6)
            WebImage(url: item.image, options: .highPriority)
                .placeholder {
                    ZStack {
                        Color.black.opacity(0.4)
                        Rectangle().fill(.thickMaterial)
                        Image(systemName: "film")
                            .foregroundColor(.secondary)
                    }
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .mask(
                    LinearGradient(gradient: Gradient(stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.5),
                        .init(color: .black.opacity(0), location: 1)
                    ]), startPoint: .top, endPoint: .bottom)
                )
                .transition(.opacity)
            if let info = item.itemGlanceInfo {
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        Text(item.itemTitle)
                            .fontWeight(.semibold)
                            .font(.callout)
                            .foregroundColor(.white)
                            .lineLimit(DrawingConstants.lineLimits)
                            .padding(.leading)
                        Spacer()
                    }
                    HStack {
                        Text(info)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(DrawingConstants.lineLimits)
                            .padding(.leading)
                            .padding(.bottom, 8)
                        Spacer()
                    }
                }
                .padding(.horizontal, 2)
            } else {
                VStack(alignment: .leading) {
                    Spacer()
                    HStack {
                        Text(item.itemTitle)
                            .fontWeight(.semibold)
                            .font(.callout)
                            .foregroundColor(.white)
                            .lineLimit(DrawingConstants.lineLimits)
                            .padding()
                        Spacer()
                    }
                    
                }
                .padding(.horizontal, 2)
            }
        }
        .frame(width: DrawingConstants.cardWidth,
               height: DrawingConstants.cardHeight)
        .cornerRadius(DrawingConstants.cardRadius)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
        .modifier(UpcomingWatchlistContextMenu(item: item))
        .padding([.leading, .trailing], 4)
        .transition(.opacity)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(item: WatchlistItem.example)
    }
}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 280
    static let cardHeight: CGFloat = 160
    static let cardRadius: CGFloat = 8
    static let shadowOpacity: Double = 0.5
    static let shadowRadius: CGFloat = 2.5
    static let lineLimits: Int = 1
}
