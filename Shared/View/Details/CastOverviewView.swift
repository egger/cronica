//
//  CastOverviewView.swift
//  Story
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct CastOverviewView: View {
    let cast: Cast
    var body: some View {
        VStack {
            AsyncImage(url: cast.profileImage) { content in
                content
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
                    .padding()
            }
            Text(cast.name)
                .fontWeight(.semibold)
                .padding(.top, -6)
            Text(cast.character ?? "")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 1)
        }
    }
}

struct CastOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        CastOverviewView(cast: Movie.previewCast)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 80
    static let profileHeight: CGFloat = 80
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
}
