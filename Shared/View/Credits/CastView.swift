//
//  CastView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastView: View {
    let cast: Cast
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    GroupBox {
                        HStack {
                            AsyncImage(url: cast.profileImage) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: DrawingConstants.imageWidth,
                                           height: DrawingConstants.imageHeight)
                                    .cornerRadius(DrawingConstants.imageRadius)
                            } placeholder: {
                                ProgressView()
                            }
                            Spacer()
                        }
                    } label: {
                        Label(cast.name ?? "", systemImage: "person")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(cast.name ?? "")
    }
}

struct CastView_Previews: PreviewProvider {
    static var previews: some View {
        CastView(cast: Movie.previewCast)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 140
    static let imageHeight: CGFloat = 220
    static let imageRadius: CGFloat = 6
}
