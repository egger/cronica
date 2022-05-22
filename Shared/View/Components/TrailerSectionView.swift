//
//  TrailerSectionView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

struct TrailerSectionView: View {
    let url: URL?
    let title: String
    @Binding var isPresented: Bool
    var body: some View {
        if let url = url {
            VStack {
                TitleView(title: "Videos", subtitle: "", image: "rectangle.stack.badge.play")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        VStack {
                            AsyncImage(url: url,
                                       transaction: Transaction(animation: .easeInOut)) { phase in
                                if let image = phase.image {
                                    ZStack {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .transition(.opacity)
                                        Color.black.opacity(0.2)
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.white)
                                            .imageScale(.large)
                                    }
                                } else if phase.error != nil {
                                    ZStack {
                                        Color.secondary
                                        ProgressView()
                                    }
                                } else {
                                    ZStack {
                                        Color.secondary
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.white)
                                            .imageScale(.large)
                                    }
                                }
                            }
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                            .padding(.horizontal)
                            .accessibilityElement(children: .combine)
                            .onTapGesture {
                                isPresented.toggle()
                            }
                            HStack {
                                Text(title)
                                    .padding([.horizontal, .bottom])
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title) trailer.")
        } else {
            EmptyView()
        }
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 160
    static let imageHeight: CGFloat = 100
}
