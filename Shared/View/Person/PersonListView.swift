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
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if !credits.cast.isEmpty {
                        ForEach(credits.cast.prefix(10)) { content in
                            NavigationLink(destination: PersonView(title: content.name, id: content.id)) {
                                PersonRectangularView(name: content.name, characterOrJob: content.character, imageUrl: content.image)
                            }
                            .padding(.leading, content.id == self.credits.cast.first!.id ? 16 : 0)
                            .padding(.trailing, content.id == self.credits.cast.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                    if !credits.crew.isEmpty {
                        ForEach(credits.crew.filter { $0.role == "Director" }) { content in
                            NavigationLink(destination: PersonView(title: content.name, id: content.id)) {
                                PersonRectangularView(name: content.name, characterOrJob: content.job, imageUrl: content.image)
                            }
                            .padding(.trailing, content.id == self.credits.cast.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        PersonListView(credits: Credits.previewCredits)
    }
}
