import SwiftUI

struct ContentListView: View {
    let type: MediaType
    let title: String
    let subtitle: String
    let image: String
    let items: [Content]
    private let context = DataController.shared
    @State private var isSharePresented: Bool = false
    @Binding var showConfirmation: Bool
    @State private var shareItems: [Any] = []
    var body: some View {
        if !items.isEmpty {
            TitleView(title: title, subtitle: subtitle, image: image)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(items) { item in
                        NavigationLink(destination: ContentDetailsView(title: item.itemTitle,
                                                                       id: item.id,
                                                                       type: type)) {
                            PosterView(title: item.itemTitle, url: item.posterImageMedium)
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
                        .padding(.leading, item.id == self.items.first!.id ? 16 : 0)
                        .padding(.trailing, item.id == self.items.last!.id ? 16 : 0)
                        .padding([.top, .bottom])
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

//struct ContentListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentListView(type: .movie,
//                        title: "Popular",
//                        subtitle: "Popular Movies",
//                        image: "crow",
//                        items: Content.previewContents)
//    }
//}
