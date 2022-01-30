//
//  CreditsProfileImageView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastProfileImage: View {
    let cast: Cast
    var body: some View {
        ZStack {
            CastImageView(url: cast.profileImage)
            CastInfoView(name: cast.name ?? "", character: cast.character ?? "")
        }
        .frame(width: DrawingConstants.profileWidth,
               height: DrawingConstants.profileHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius, style: .continuous))
        .padding(2)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

struct CreditsProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        CastProfileImage(cast: Movie.previewCast)
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

struct CastImageView: View {
    let url: URL
    var body: some View {
        ZStack {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
                Rectangle()
                    .fill(.black.opacity(0.8))
                    .background(.thinMaterial)
                image
                    .resizable()
                    .scaledToFill()
                    .mask {
                        LinearGradient(gradient: Gradient(colors:
                                                            [.black,
                                                             .black.opacity(0)]),
                                       startPoint: .center,
                                       endPoint: .bottom)
                    }
            } placeholder: {
                Rectangle()
                    .fill(.secondary)
                    .redacted(reason: .placeholder)
            }
        }
    }
}

struct CastInfoView: View {
    let name: String
    let character: String?
    var body: some View {
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
            if !character.isEmpty {
                HStack {
                    Text(character!)
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
}
