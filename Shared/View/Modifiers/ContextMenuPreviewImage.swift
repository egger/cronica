//
//  ContextMenuPreviewImage.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI
import NukeUI

struct ContextMenuPreviewImage: View {
    let title: String
    let image: URL?
    let overview: String
    var body: some View {
        ZStack {
            LazyImage(url: image) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    ZStack {
                        Rectangle().fill(.regularMaterial)
                        Label(title, systemImage: "popcorn.fill")
                            .font(.title3)
                            .fontDesign(.rounded)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(width: 300, height: 180)
                }
            }
            .overlay {
                if image != nil {
                    VStack(alignment: .leading) {
                        Spacer()
                        ZStack(alignment: .bottom) {
                            Color.black.opacity(0.4)
                                .frame(height: 70)
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
                                .frame(height: 100)
                                .mask {
                                    VStack(spacing: 0) {
                                        LinearGradient(colors: [Color.black.opacity(0),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.924),
                                                                Color.black],
                                                       startPoint: .top,
                                                       endPoint: .bottom)
                                        .frame(height: 70)
                                        Rectangle()
                                    }
                                }
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(title)
                                        .font(.callout)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .padding(overview.isEmpty ? [.horizontal, .bottom] : .horizontal)
                                    Spacer()
                                }
                                if !overview.isEmpty {
                                    Text(overview)
                                        .lineLimit(2)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.bottom, 16)
                                        .padding(.top, 2)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContextMenuPreviewImage(title: ItemContent.example.itemTitle,
                            image: ItemContent.example.cardImageMedium,
                            overview: ItemContent.example.itemOverview)
}
