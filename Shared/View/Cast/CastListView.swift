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
    let credits: Credits?
    var body: some View {
        if let credits {
            VStack(alignment: .leading) {
                HStack {
                    Text("Cast & Crew")
                        .padding([.horizontal, .top])
                    Spacer()
                }
                .unredacted()
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack {
                        ForEach(credits.cast.prefix(10)) { cast in
                            NavigationLink(value: cast) {
                                PersonCardView(person: cast)
                                    .shadow(radius: DrawingConstants.shadowRadius)
                                    .padding(.leading, cast.id == self.credits?.cast.first!.id ? 16 : 0)
                                    .contextMenu {
                                        ShareLink(item: cast.itemURL)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                        ForEach(credits.crew.filter { $0.personRole == "Director" }) { director in
                            NavigationLink(value: director) {
                                PersonCardView(person: director)
                                    .shadow(radius: DrawingConstants.shadowRadius)
                                    .contextMenu {
                                        ShareLink(item: director.itemURL)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding([.top, .bottom])
                    .padding(.trailing)
                })
            }
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        CastListView(credits: Credits.previewCredits)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 2
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}
