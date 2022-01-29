//
//  CastDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 20/01/22.
//

import SwiftUI

struct CastDetailsView: View {
    let content: Cast
    var body: some View {
        VStack {
            ScrollView {
                GroupBox {
                    HStack {
                        AsyncImage(url: content.profileImage) { content in
                            content
                                .resizable()
                                .frame(width: DrawingConstants.imageWidth,
                                       height: DrawingConstants.imageHeight)
                                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                            style: .continuous))
                        } placeholder: {
                            ProgressView()
                                .padding()
                        }
                        Spacer()
                    }
                } label: {
                    Label(content.name, systemImage: "person")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            VStack {
                HStack {
                    Text("Know for")
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                        .padding([.horizontal, .top])
                    Spacer()
                }
            }
            Spacer()
        }
        .navigationTitle(content.name)
    }
}

struct CastDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CastDetailsView(content: Movie.previewCast)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 180
    static let imageRadius: CGFloat = 8
}
