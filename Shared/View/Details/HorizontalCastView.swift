//
//  HorizontalCastView.swift
//  Story
//
//  Created by Alexandre Madeira on 17/01/22.
//

import SwiftUI

struct HorizontalCastView: View {
    let cast: [Cast]

    var body: some View {
        VStack {
            HStack {
                Text("Cast & Crew")
                    .textCase(.uppercase)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding([.top, .horizontal])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(cast) { content in
                        NavigationLink(destination: CastDetailsView(content: content)) {
                            CastOverviewView(cast: content)
                                .padding([.leading, .trailing],
                                         DrawingConstants.overviewPadding)
                        }
                        .padding(.leading, content.id == self.cast.first!.id ? 16 : 0)
                        .padding(.trailing, content.id == self.cast.last!.id ? 16 : 0)
                    }
                }
            }
        }
    }
}

struct HorizontalCastView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalCastView(cast: Movie.previewCredits)
    }
}

private struct DrawingConstants {
    static let overviewPadding: CGFloat = 4
}
