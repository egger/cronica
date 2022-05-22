//
//  TrendingListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct TrendingListView: View {
    let items: [Content]?
    private let context = DataController.shared
    @State private var isSharePresented: Bool = false
    @State private var shareItems: [Any] = []
    @Binding var showConfirmation: Bool
    var body: some View {
        if let items = items {
            VStack {
                TitleView(title: "Trending", subtitle: "This week", image: "crown")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: ContentDetailsView(title: item.itemTitle,
                                                                           id: item.id,
                                                                           type: item.itemContentMedia)) {
                                PosterView(title: item.itemTitle, url: item.posterImageMedium)
                                    .contextMenu {
                                        Button(action: {
                                            shareItems = [item.itemURL]
                                            withAnimation {
                                                isSharePresented.toggle()
                                            }
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
    
    private func updateWatchlist(item: Content) async {
        HapticManager.shared.softHaptic()
        if !context.isItemInList(id: item.id) {
            let content = try? await NetworkService.shared.fetchContent(id: item.id, type: item.media)
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

//struct TrendingView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrendingListView(items: Content.previewContents)
//    }
//}
