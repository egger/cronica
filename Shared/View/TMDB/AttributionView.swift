//
//  AttributionView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 06/03/22.
//

import SwiftUI

struct AttributionView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("PrimaryCompact")
                .resizable()
                .scaledToFit()
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight,
                       alignment: .center)
                .accessibility(hidden: true)
            Text("This product uses the TMDb API but is not endorsed or certified by TMDb.")
                .frame(alignment: .center)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding([.horizontal, .bottom])
        }
        .accessibilityElement(children: .combine)
        .unredacted()
    }
}

struct AttributionView_Previews: PreviewProvider {
    static var previews: some View {
        AttributionView()
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 40
}
