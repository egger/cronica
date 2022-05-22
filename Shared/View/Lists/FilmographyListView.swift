//
//  FilmographyListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

struct FilmographyListView: View {
    let items: [Filmography]?
    private let context = DataController.shared
    @Binding var showConfirmation: Bool
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
    var body: some View {
        if let items = items {
            VStack {
                TitleView(title: "Filmography", subtitle: "Know for", image: "list.and.film")
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(items.sorted(by: { $0.itemPopularity > $1.itemPopularity } )) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle,
                                                                    id: item.id,
                                                                    type: item.itemMedia)) {
                                PosterView(title: item.itemTitle, url: item.itemImage)
                                    .contextMenu {
                                        Button(action: {
                                            shareItems = [item.itemURL]
                                            isSharePresented.toggle()
                                        }, label: {
                                            Label("Share",
                                                  systemImage: "square.and.arrow.up")
                                        })
                                        Button(action: {
                                            Task {
                                                await updateWatchlist(item: item)
                                            }
                                        }, label: {
                                            Label("Add to watchlist", systemImage: "plus.circle")
                                        })
                                    }
                                    .padding([.leading, .trailing], 4)
                                    .sheet(isPresented: $isSharePresented,
                                           content: { ActivityViewController(itemsToShare: $shareItems) })
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, item.id == items.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == items.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
    
    private func updateWatchlist(item: Filmography) async {
        HapticManager.shared.softHaptic()
        if !context.isItemInList(id: item.id) {
            let content = try? await NetworkService.shared.fetchContent(id: item.id, type: item.itemMedia)
            if let content = content {
                withAnimation {
                    context.saveItem(content: content, notify: content.itemCanNotify)
                    showConfirmation.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        showConfirmation = false
                    }
                }
            }
        }
    }
}
