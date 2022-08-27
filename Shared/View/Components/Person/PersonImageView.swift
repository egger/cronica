//
//  ProfileImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

/// This view displays a rounded image for the given person.
struct PersonImageView: View {
    let url: URL?
    let name: String
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
#if os(watchOS)
                    Rectangle().fill(.secondary)
#else
                    Rectangle().fill(.thickMaterial)
#endif
                    ProgressView()
                }
            }
        }
        .clipShape(Circle())
        .padding([.top, .bottom])
        .accessibilityHidden(true)
    }
}

struct Previews_ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        PersonImageView(url: Person.previewCast.personImage,
                        name: Person.previewCast.name)
    }
}
