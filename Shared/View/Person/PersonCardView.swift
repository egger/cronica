//
//  PersonCardView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct PersonCardView: View {
    let name: String
    let characterOrJob: String?
    let url: URL?
    var body: some View {
        ZStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                Rectangle().fill(.ultraThickMaterial)
                Color.black.opacity(0.6)
                image
                    .resizable()
                    .scaledToFill()
                    .mask(
                        LinearGradient(gradient: Gradient(stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.1),
                            .init(color: .black.opacity(0), location: 1)
                        ]), startPoint: .center, endPoint: .bottom)
                    )
            } placeholder: {
                ZStack {
                    Color.secondary
                    ProgressView()
                }
            }
            VStack {
                Spacer()
                HStack {
                    Text(name)
                        .foregroundColor(.white)
                        .lineLimit(DrawingConstants.lineLimit)
                        .padding(.leading, 6)
                        .padding(.bottom, 1)
                    Spacer()
                }
                if characterOrJob.isEmpty {
                    EmptyView()
                } else {
                    HStack {
                        Text(characterOrJob!)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                            .lineLimit(1)
                            .padding(.leading, 6)
                            .padding(.bottom)
                        Spacer()
                    }
                }
            }
        }
        .frame(width: DrawingConstants.profileWidth,
               height: DrawingConstants.profileHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius,
                                    style: .continuous))
        .padding(2)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

struct PersonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PersonCardView(name: Credits.previewCast.name,
                       characterOrJob: Credits.previewCast.role,
                       url: Credits.previewCast.mediumImage)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}
