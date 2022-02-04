//
//  HorizontalSeriesListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct HorizontalSeriesListView: View {
    let style: String
    let title: String
    let series: [Series]
    var body: some View {
        VStack {
            SectionHeaderView(title: title)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(series) { item in
                        switch style {
                        case "poster":
                            PosterView(title: item.title,
                                       url: item.posterImage)
                                .padding([.leading, .trailing], 4)
                        case "card":
                            CardView(title: item.title,
                                     url: item.backdropImage)
                                .padding([.leading, .trailing], 4)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}

//struct HorizontalSeriesListView_Previews: PreviewProvider {
//    static var previews: some View {
//        HorizontalSeriesListView(style: "poster", title: "latest", series: Series.previewSeries)
//        HorizontalSeriesListView(style: "card", title: "airing today", series: Series.previewSeries)
//    }
//}
