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
//                    Button(action: {
//                        withAnimation {
//                            HapticManager.shared.mediumHaptic()
//                            markAsWatched.toggle()
//                        }
//                    }, label: {
//                        Label(markAsWatched ? "Remove from Watched" : "Mark as Watched",
//                              systemImage: markAsWatched ? "minus.circle" : "checkmark.circle")
//                    })
//                    .buttonStyle(.borderedProminent)
//                    .controlSize(.large)
//                    .tint(markAsWatched ? .red : .green)
                    OverviewBoxView(overview: item.overview, type: .tvShow)
                        .onTapGesture {
                            showOverview.toggle()
                        }
                        .padding([.horizontal, .bottom])
                }
                .sheet(isPresented: $showOverview) {
                    NavigationView {
                        ScrollView {
                            Text(item.overview ?? "Not Available")
                                .padding()
                        }
                        .navigationTitle(item.itemTitle)
                        .navigationBarTitleDisplayMode(.inline)
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
