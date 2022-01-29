//
//  CreditsProfileImageView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CreditsProfileImageView: View {
    let url: URL
    let name: String
    let job: String?
    let character: String?
    var body: some View {
        VStack {
            AsyncImage(url: url) { image in
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
                ProgressView()
            }
            Text(name)
                .fontWeight(.semibold)
                .padding(.top, -6)
            Text((job ?? character) ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 1)
        }
    }
}

struct CreditsProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsProfileImageView(url: Credits.previewCast.profileImage, name: Credits.previewCast.name, job: nil, character: Credits.previewCast.character)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 80
    static let profileHeight: CGFloat = 80
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
}
