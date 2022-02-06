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
                    AsyncImage(url: cast.image) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                            .clipShape(Circle())
                            .padding([.top, .bottom])
                    } placeholder: {
                        ProgressView()
                    }
                }
                GroupBox {
                    Text(cast.biography ?? "")
                        .padding([.top, .bottom], 4)
                } label: {
                    Label("biography", systemImage: "book")
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle(cast.name )
    }
}

struct CastView_Previews: PreviewProvider {
    static var previews: some View {
        CastView(cast: Credits.previewCast)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
}
