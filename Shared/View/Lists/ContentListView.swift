import SwiftUI

struct ContentListView: View {
    let type: MediaType
    let title: String
    let subtitle: String
    let image: String
    let items: [ItemContent]
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
                                .modifier(ItemContentContext(shareItems: $shareItems, item: item, isSharePresented: $isSharePresented, showConfirmation: $showConfirmation))
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
}

struct ContentListView_Previews: PreviewProvider {
    @State private static var showConfirmation: Bool = false
    static var previews: some View {
        ContentListView(type: .movie,
                        title: "Popular",
                        subtitle: "Popular Movies",
                        image: "crow",
                        items: ItemContent.previewContents,
                        showConfirmation: $showConfirmation)
    }
}
