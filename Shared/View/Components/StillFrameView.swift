//
//  StillFrameView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 01/05/22.
//

import SwiftUI


struct StillFrameView: View {
    let item: Content
    var body: some View {
        VStack {
            AsyncImage(url: item.cardImageMedium,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                } else if phase.error != nil {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            Text(item.itemTitle)
                                .font(.callout)
                                .lineLimit(1)
                                .padding(.bottom)
                            Image(systemName: "film")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                } else {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        VStack {
                            ProgressView()
                                .padding(.bottom)
                            Image(systemName: "film")
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                }
            }
            .frame(width: 160, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8,
                                        style: .continuous))
            HStack {
                Text(item.itemTitle)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .lineLimit(1)
                    .padding(.leading)
                Spacer()
            }
        }
    }
}

struct StillFrameView_Previews: PreviewProvider {
    static var previews: some View {
        StillFrameView(item: Content.previewContent)
    }
}
