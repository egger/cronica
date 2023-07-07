//
//  OverviewBoxView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/22.
//

import SwiftUI
#if !os(tvOS)
/// Displays the overview of a movie, tv show, or episode.
/// It can also display biography.
struct OverviewBoxView: View {
    let overview: String?
    let title: String
    var type: MediaType = .movie
    @State private var showFullText = false
    @State private var showSheet = false
    @State private var showTextOptions = true
    @State private var isTruncated = false
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        if let overview {
            if !overview.isEmpty {
                GroupBox {
                    VStack(alignment: .leading) {
                        Text(overview)
                            .font(.callout)
                            .padding([.top], 2)
                            .lineLimit(showFullText ? nil : 4)
                        
#if os(iOS)
                        Text(showFullText ? "Collapse" : "Show More")
                            .fontDesign(.rounded)
                            .textCase(.uppercase)
                            .font(.caption)
                            .foregroundStyle(settings.appTheme.color)
                            .padding(.top, 4)
#endif
                    }
                } label: {
                    Text("About")
                        .unredacted()
                }
                .onTapGesture {
#if os(iOS)
                    withAnimation { showFullText.toggle() }
#elseif os(macOS)
                    showSheet.toggle()
#endif
                }
                .accessibilityElement(children: .combine)
                .contextMenu {  ShareLink(item: overview) }
#if os(macOS)
                .popover(isPresented: $showSheet) {
                    ScrollView {
                        Text(overview )
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
    }
    
#if os(iOS)
    
#endif
}

struct OverviewBoxView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewBoxView(overview: ItemContent.example.overview,
                        title: ItemContent.example.itemTitle,
                        type: .movie)
    }
}
#endif
