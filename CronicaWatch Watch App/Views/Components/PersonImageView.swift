//
//  PersonImageView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct PersonImageView: View {
    let image: URL?
    var body: some View {
        AsyncImage(url: image) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                Rectangle().redacted(reason: .placeholder)
            } else {
                ZStack {
                    Rectangle().fill(.secondary)
                    ProgressView()
                }
            }
        }
        .frame(width: DrawingConstants.imageWidth,
               height: DrawingConstants.imageHeight)
        .clipShape(Circle())
        .padding([.top, .bottom])
        .accessibilityHidden(true)
    }
}

struct PersonImageView_Previews: PreviewProvider {
    static var previews: some View {
        PersonImageView(image: Person.previewCast.personImage)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 100
    static let imageHeight: CGFloat = 100
}
