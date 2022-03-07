//
//  AttributionView.swift
//  Story
//
//  Created by Alexandre Madeira on 06/03/22.
//

import SwiftUI

struct AttributionView: View {
    var body: some View {
        VStack {
            Text("This product uses the TMDB API but is not endorsed or certified by TMDB.")
                .frame(alignment: .center)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Image("PrimaryCompact")
                .resizable()
                .scaledToFit()
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight,
                       alignment: .center)
                .padding(.bottom)
        }
    }
}

struct AttributionView_Previews: PreviewProvider {
    static var previews: some View {
        AttributionView()
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 140
    static let imageHeight: CGFloat = 40
}
