//
//  ProfileImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

/// This view displays a rounded image for the given person.
struct ProfileImageView: View {
    let url: URL?
    let name: String
    @State private var isPad: Bool = UIDevice.isIPad
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if phase.error != nil {
                Rectangle().redacted(reason: .placeholder)
            } else {
                ZStack {
                    Rectangle().fill(.thickMaterial)
                    ProgressView()
                }
            }
        }
        .frame(width: isPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
               height: isPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
        .clipShape(Circle())
        .padding([.top, .bottom])
        .accessibilityHidden(true)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
    static let padImageWidth: CGFloat = 250
    static let padImageHeight: CGFloat = 250
}

struct Previews_ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView(url: Person.previewCast.personImage,
                         name: Person.previewCast.name)
    }
}
