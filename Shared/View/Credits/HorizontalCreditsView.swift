//
//  HorizontalCreditsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct HorizontalCreditsView: View {
    let cast: [Cast]
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Cast & Crew")
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(cast) { item in
                        NavigationLink(destination: CastView()) {
                            CastProfileImage(cast: item)
                        }
                        .padding(.leading, item.id == self.cast.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == self.cast.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
                    }
                }
            }
        }
    }
}

struct HorizontalCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalCreditsView(cast: Movie.previewCasts)
    }
}
