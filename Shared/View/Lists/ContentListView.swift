import SwiftUI

struct ContentListView: View {
    let type: MediaType
    let title: String
    let subtitle: String
    let image: String
    let items: [Content]
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
                                .padding([.leading, .trailing], 4)
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
    static var previews: some View {
        ContentListView(type: .movie,
                        title: "Popular",
                        subtitle: "Popular Movies",
                        image: "crow",
                        items: Content.previewContents)
    }
}
