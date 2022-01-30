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
        VStack {
            AsyncImage(url: cast.profileImage) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: DrawingConstants.profileWidth,
                           height: DrawingConstants.profileHeight,
                           alignment: .center)
                    .clipShape(Circle())
                    .padding()
                    .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                            radius: DrawingConstants.shadowRadius)
            } placeholder: {
                Circle()
                    .fill(.secondary)
                    .frame(width: DrawingConstants.profileWidth,
                           height: DrawingConstants.profileHeight)
                    .padding()
                    .redacted(reason: .placeholder)
            }
            Text(cast.name ?? "")
                .fontWeight(.semibold)
                .padding(.top, -6)
            Text(cast.character ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 1)
        }
    }
}

struct CreditsProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        CastProfileImage(cast: Movie.previewCast)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 80
    static let profileHeight: CGFloat = 80
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
}
