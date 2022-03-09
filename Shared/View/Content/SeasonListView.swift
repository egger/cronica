//
//  SeasonListView.swift
//  Story
//
//  Created by Alexandre Madeira on 08/03/22.
//

import SwiftUI

struct SeasonListView: View {
    let title: String
    let id: Int
    let items: [Season]
    var body: some View {
        VStack {
            if !items.isEmpty {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.headline)
                        .padding([.horizontal, .top])
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: SeasonDetailsView(id: id, seasonNumber: item.seasonNumber, title: item.itemTitle)) {
                                PosterView(title: item.itemTitle, url: item.posterImage)
                                    .padding([.leading, .trailing], 4)
                            }
                            .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            } 
        }
    }
}

//struct SeasonListView_Previews: PreviewProvider {
//    static var previews: some View {
//        SeasonListView()
//    }
//}
