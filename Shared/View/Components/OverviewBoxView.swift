//
//  OverviewBoxView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/22.
//

import SwiftUI

/// Displays the overview of a movie, tv show, or episode.
/// It can also display biography.
struct OverviewBoxView: View {
    let overview: String?
    let title: String
    var type: MediaType = .movie
    @State private var showDetailsSheet: Bool = false
    var body: some View {
        GroupBox {
            Text(overview ?? "Not Available")
                .padding([.top], 2)
                .lineLimit(4)
        } label: {
            switch type {
            case .person:
                Label("Biography", systemImage: "book")
                    .unredacted()
            case .tvShow:
                Label("About", systemImage: "film")
                    .unredacted()
            default:
                Label("About", systemImage: "film")
                    .unredacted()
            }
        }
        .onTapGesture {  showDetailsSheet.toggle() }
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $showDetailsSheet) {
            NavigationStack {
                ScrollView {
                    Text(overview ?? NSLocalizedString("Not Available.", comment: ""))
                        .padding()
                        .textSelection(.enabled)
                }
                .navigationTitle(title)
                .toolbar {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button("Done") {
                            showDetailsSheet.toggle()
                        }
                    })
#else
                    ToolbarItem {
                        Button("Done") {
                            showDetailsSheet.toggle()
                        }
                    }
#endif
                }
            }
        }
        .contextMenu { if let overview { ShareLink(item: overview) } }
    }
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewBoxView(overview: ItemContent.previewContent.overview,
                        title: ItemContent.previewContent.itemTitle,
                        type: .movie)
    }
}
