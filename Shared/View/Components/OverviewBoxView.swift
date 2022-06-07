//
//  OverviewBoxView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/22.
//

import SwiftUI

struct OverviewBoxView: View {
    let overview: String?
    let title: String
    let type: MediaType
    @State private var showDetailsSheet: Bool = false
    var body: some View {
        GroupBox {
            Text(overview ?? "Not Available")
                .padding([.top], 2)
                .lineLimit(4)
        } label: {
            switch type {
            case .movie:
                Label("About", systemImage: "film")
                    .unredacted()
            case .person:
                Label("Biography", systemImage: "book")
                    .unredacted()
            case .tvShow:
                Label("About", systemImage: "film")
                    .unredacted()
            }
        }
        .onTapGesture {
            HapticManager.shared.lightHaptic()
            showDetailsSheet.toggle()
        }
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $showDetailsSheet, content: {
            NavigationStack {
                ScrollView {
                    if let overview {
                        Text(overview)
                            .padding()
                            .textSelection(.enabled)
                    } else {
                        Text("Not Available.")
                            .padding()
                    }
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing, content: {
                        Button("Done") {
                            showDetailsSheet.toggle()
                        }
                    })
                }
            }
        })
    }
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewBoxView(overview: ItemContent.previewContent.overview,
                        title: ItemContent.previewContent.itemTitle,
                        type: .movie)
    }
}
