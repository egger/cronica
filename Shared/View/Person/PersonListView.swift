//
//  PersonListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct PersonListView: View {
    let credits: Credits
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Cast & Crew")
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if credits.cast.isEmpty {
                        EmptyView()
                    } else {
                        ForEach(credits.cast.prefix(10)) { content in
                            NavigationLink(destination: PersonView(title: content.name, id: content.id)) {
                                PersonCardView(name: content.name,
                                               characterOrJob: content.role,
                                               url: content.mediumImage)
                            }
                            .padding(.leading, content.id == self.credits.cast.first!.id ? 16 : 0)
                        }
                    }
                    if credits.crew.isEmpty {
                        EmptyView()
                    } else {
                        ForEach(credits.crew.filter { $0.role == "Director" }) { content in
                            NavigationLink(destination: PersonView(title: content.name, id: content.id)) {
                                PersonCardView(name: content.name, characterOrJob: content.role, url: content.mediumImage)
                            }
                        }
                    }
                }
                .padding([.top, .bottom])
                .padding(.trailing)
            }
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonListView(credits: Credits.previewCredits)
    }
}
