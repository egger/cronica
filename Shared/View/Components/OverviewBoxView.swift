//
//  OverviewBoxView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
/// Displays the overview of a movie, tv show, or episode.
/// It can also display biography.
struct OverviewBoxView: View {
    let overview: String?
    let title: String
    var type: MediaType = .movie
    @State private var showFullText = false
    @State private var showSheet = false
    var body: some View {
        GroupBox {
            Text(overview ?? "Not Available")
                .padding([.top], 2)
                .lineLimit(showFullText ? nil : 4)
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
        .onTapGesture {
#if os(iOS) || os(watchOS)
            withAnimation { showFullText.toggle() }
#elseif os(macOS)
            showSheet.toggle()
#endif
        }
        .accessibilityElement(children: .combine)
        .contextMenu { if let overview { ShareLink(item: overview) } }
#if os(macOS)
        .popover(isPresented: $showSheet) {
            ScrollView {
                Text(overview ?? "No Overview")
                    .unredacted()
                    .padding()
            }
            .frame(width: 400, height: 200, alignment: .center)
        }
#elseif os(iOS)
        .groupBoxStyle(TransparentGroupBox())
#endif
    }
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewBoxView(overview: ItemContent.example.overview,
                        title: ItemContent.example.itemTitle,
                        type: .movie)
    }
}
#endif
