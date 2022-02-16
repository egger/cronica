//
//  TVListView.swift
//  Story
//
//  Created by Alexandre Madeira on 08/02/22.
//

import SwiftUI

struct TVListView: View {
    let style: StyleType
    let title: String
    let series: [TVShow]?
    var body: some View {
        if series.isEmpty {
            EmptyView()
        } else {
            VStack {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding([.top, .horizontal])
                    Spacer()
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(series!) { content in
                            NavigationLink(destination: TVDetailsView(title: content.title, id: content.id)) {
                                switch style {
                                case .poster:
                                    PosterView(title: content.title, url: content.posterImage)
                                        .padding([.leading, .trailing], 4)
                                case .card:
                                    CardView(title: content.title, url: content.backdropImage)
                                        .padding([.leading, .trailing], 4)
                                }
                            }
                            .padding(.leading, content.id == self.series!.first!.id ? 16 : 0)
                            .padding(.trailing, content.id == self.series!.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

//struct TVListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TVListView()
//    }
//}
