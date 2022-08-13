//
//  HeroImagePlaceholder.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct HeroImagePlaceholder: View {
    let title: String
    var body: some View {
        ZStack {
            Rectangle().fill(.secondary)
            VStack {
                Text(title)
                    .font(.callout)
                    .lineLimit(DrawingConstants.lineLimits)
                    .padding(.bottom)
                Image(systemName: "film")
            }
            .foregroundColor(.white)
            .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                    style: .continuous))
        .padding()
    }
}

struct HeroImagePlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        HeroImagePlaceholder(title: "Preview Title")
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 12
    static let lineLimits: Int = 1
}
