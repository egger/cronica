//
//  CastListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

/// A horizontal list that displays a limited number of
///  cast people in an ItemContent.
struct CastListView: View {
    let credits: [Person]
    var body: some View {
        if !credits.isEmpty {
            VStack(alignment: .leading) {
                TitleView(title: "Cast & Crew", subtitle: "", image: "person.3", showChevron: false)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(credits, id: \.personListID) { person in
                            PersonCardView(person: person)
                                .padding(.leading, person.id == self.credits.first!.id ? 16 : 0)
                                .buttonStyle(.plain)
                                .applyHoverEffect()
                        }
                    }
                    .padding([.top, .bottom])
                    .padding(.trailing)
                }
            }
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        CastListView(credits: Person.example)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 2
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}
