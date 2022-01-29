//
//  HorizontalSeriesListView.swift
//  Story
//
//  Created by Alexandre Madeira on 28/01/22.
//

import SwiftUI

//struct HorizontalSeriesListView: View {
//    let style: String
//    let title: String
//    let series: [Series]
//    var body: some View {
//        VStack {
//            SectionHeaderView(title: title)
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(series) { item in
//                        NavigationLink(destination: DetailsView(id: item.id)) {
//                            switch style {
//                            case "poster":
//                                PosterView(title: item.name,
//                                           url: item.posterImage)
//                                    .padding([.leading, .trailing], 4)
//                            case "card":
//                                CardView(title: item.name,
//                                         url: item.backdropImage)
//                                    .padding([.leading, .trailing], 4)
//                            default:
//                                EmptyView()
//                            }
//                        }
//                        .padding(.leading, item.id == self.movies.first!.id ? 16 : 0)
//                        .padding(.trailing, item.id == self.movies.last!.id ? 16 : 0)
//                        .padding([.top, .bottom])
//                    }
//                }
//            }
//        }
//    }
//}

//struct HorizontalSeriesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        HorizontalSeriesListView()
//    }
//}
