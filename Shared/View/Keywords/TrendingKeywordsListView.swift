//
//  TrendingKeywordsListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrendingKeywordsListView: View {
    @State private var trendingKeywords = [CombinedKeywords]()
    @State private var isLoading = true
	private let columns = [GridItem(.adaptive(minimum: 160))]
    private let keywords: [CombinedKeywords] = [
        .init(id: 210024, name: NSLocalizedString("Anime", comment: ""), image: nil),
        .init(id: 41645, name: NSLocalizedString("Based on Video-Game", comment: ""), image: nil),
        .init(id: 9715, name: NSLocalizedString("Superhero", comment: ""), image: nil),
        .init(id: 9799, name: NSLocalizedString("Romantic Comedy", comment: ""), image: nil),
        .init(id: 9672, name: NSLocalizedString("Based on true story", comment: ""), image: nil),
        .init(id: 256183, name: NSLocalizedString("Supernatural Horror", comment: ""), image: nil),
        .init(id: 10349, name: NSLocalizedString("Survival", comment: ""), image: nil),
        .init(id: 9882, name: NSLocalizedString("Space", comment: ""), image: nil),
        .init(id: 818, name: NSLocalizedString("Based on novel or book", comment: ""), image: nil),
        .init(id: 9951, name: NSLocalizedString("Alien", comment: ""), image: nil),
        .init(id: 189402, name: NSLocalizedString("Crime Investigation", comment: ""), image: nil),
        .init(id: 161184, name: NSLocalizedString("Reboot", comment: ""), image: nil),
        .init(id: 15285, name: NSLocalizedString("Spin off", comment: ""), image: nil)
    ]
    private var service: NetworkService = NetworkService.shared
    var body: some View {
		VStack {
			if !trendingKeywords.isEmpty {
				TitleView(title: "Trending Keywords").unredacted()
				ScrollView {
					LazyVGrid(columns: columns, spacing: 20) {
						ForEach(trendingKeywords) { keyword in
                            if keyword.image != nil {
                                trendingCard(keyword)
                            }
						}
					}
					.padding([.horizontal, .bottom])
				}
			}
		}
        .task { await load() }
		.redacted(reason: isLoading ? .placeholder : [])
    }
    
    private func trendingCard(_ keyword: CombinedKeywords) -> some View {
        NavigationLink(value: keyword) {
            WebImage(url: keyword.image, options: [.continueInBackground, .highPriority])
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .overlay {
                    ZStack {
                        Rectangle().fill(.black.opacity(0.5))
                        VStack {
                            Spacer()
                            HStack {
                                Text(keyword.name)
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
                .frame(width: 160, height: 100, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(radius: 2)
                .buttonStyle(.plain)
        }
        .disabled(isLoading)
        .frame(width: 160, height: 100, alignment: .center)
    }
}

#Preview {
    TrendingKeywordsListView()
}

extension TrendingKeywordsListView {
    private func load() async {
        if trendingKeywords.isEmpty {
            for item in keywords.sorted(by: { $0.name < $1.name}) {
                let itemFromKeyword = try? await service.fetchKeyword(type: .movie,
                                                                      page: 1,
                                                                      keywords: item.id,
                                                                      sortBy: TMDBSortBy.popularity.rawValue)
                var url: URL?
                if let firstItem = itemFromKeyword?.first {
                    url = firstItem.cardImageMedium
                }
                let content: CombinedKeywords = .init(id: item.id, name: item.name, image: url)
                trendingKeywords.append(content)
            }
            withAnimation {
                isLoading = false
            }
        }
    }
}

struct CombinedKeywords: Identifiable, Hashable {
    let id: Int
    let name: String
    let image: URL?
}
