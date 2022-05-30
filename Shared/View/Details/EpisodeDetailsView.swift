//
//  EpisodeDetailsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 28/04/22.
//

import SwiftUI

struct EpisodeDetailsView: View {
    @Binding var item: Episode?
    @State private var markAsWatched: Bool = false
    @State private var showOverview: Bool = false
    var body: some View {
        ScrollView {
            if let item = item {
                VStack {
                    HeroImage(url: item.itemImageLarge, title: item.itemTitle)
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .cornerRadius(DrawingConstants.imageRadius)
                    
                    OverviewBoxView(overview: item.overview, title: item.itemTitle, type: .tvShow)
                        .padding()
                }
                .sheet(isPresented: $showOverview) {
                    NavigationView {
                        ScrollView {
                            Text(item.overview ?? "Not Available")
                                .padding()
                        }
                        .navigationTitle(item.itemTitle)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationViewStyle(.stack)
                        .toolbar {
                            ToolbarItem {
                                Button("Done") {
                                    showOverview.toggle()
                                }
                            }
                        }
                    }
                }
                .navigationTitle(item.itemTitle)
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let padImageWidth: CGFloat = 660
    static let padImage: CGFloat = 510
    static let imageRadius: CGFloat = 8
}
