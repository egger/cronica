//
//  HorizontalCreditsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct HorizontalCreditsView: View {
    let cast: [Cast]
    let crew: [Crew]
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
                        NavigationLink(destination: CastView(cast: item)) {
                            CreditProfileImage(name: item.name ?? "", characterOrJob: item.character ?? "", imageUrl: item.profileImage)
                        }
                        .padding(.leading, item.id == self.cast.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == self.cast.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
                    }
                    if !crew.isEmpty {
                        ForEach(crew) { item in
                            CreditProfileImage(name: item.name, characterOrJob: item.job ?? "", imageUrl: item.profileImage)
                        }
                    }
                }
            }
        }
    }
}

struct HorizontalCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalCreditsView(cast: Movie.previewCasts, crew: Movie.previewCrew)
    }
}
