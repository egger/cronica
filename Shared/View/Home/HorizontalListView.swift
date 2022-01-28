//
//  HorizontalListView.swift
//  Story
//
//  Created by Alexandre Madeira on 16/01/22.
//

import SwiftUI

struct HorizontalListView: View {
    let sectionStyle: String
    let sectionTitle: String
    let items: [Movie]
    var body: some View {
        LazyVStack {
            SectionHeader(title: sectionTitle)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        NavigationLink(destination: MovieDetailsView(movie: item)) {
                            if sectionStyle == "poster" {
                                PosterView(content: item)
                                    .contextMenu {
                                        Button {
                                            print("watchlist context menu")
                                        } label: {
                                            Label("Add to watchlist", systemImage: "bell.square")
                                        }
                                        Button {
                                            print("share context menu")
                                        } label: {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                    }
                                    .padding([.leading, .trailing], 4)
                            } else if sectionStyle == "card" {
                                CardView(movie: item)
                                    .contextMenu {
                                        Button {
                                            print("watchlist context menu")
                                        } label: {
                                            Label("Add to watchlist", systemImage: "bell.square")
                                        }
                                        Button {
                                            print("share context menu")
                                        } label: {
                                            Label("Share", systemImage: "square.and.arrow.up")
                                        }
                                    }
                                    .padding([.leading, .trailing], 4)
                            } else {
                                Text("")
                            }
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

struct HorizontalListView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalListView(sectionStyle: "card", sectionTitle: "popular", items: Movie.previewMovies)
    }
}
