//
//  WatchProvidersList.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 14/01/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchProvidersList: View {
    @StateObject private var viewModel = WatchProvidersListViewModel()
    let id: ItemContent.ID
    let type: MediaType
    var body: some View {
        VStack {
            if viewModel.isProvidersAvailable {
                TitleView(title: "watchProviderTitleList",
                          subtitle: "",
                          image: "rectangle.stack.badge.play.fill",
                          showChevron: false)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.items, id: \.self) { item in
                            WatchProviderItem(item: item)
                                .buttonStyle(.plain)
                                .padding(.horizontal, 4)
                                .padding(.leading, item.contentId == viewModel.items.first!.contentId ? 16 : 0)
                                .padding(.leading, item.contentId == viewModel.items.last!.contentId ? 16 : 0)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
        .task {
            await viewModel.load(id: id, media: type)
        }
    }
}

struct WatchProviderItem: View {
    let item: Buy
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: item.providerImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            Text(item.providerTitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: 80, height: 100, alignment: .center)
    }
}

//struct WatchProvidersList_Previews: PreviewProvider {
//    static var previews: some View {
//        WatchProvidersList()
//    }
//}

class WatchProvidersListViewModel: ObservableObject {
    @Published var isProvidersAvailable = false
    @Published var items = [Buy]()
    
    @MainActor
    func load(id: ItemContent.ID, media: MediaType) async {
        do {
            let providers = try await NetworkService.shared.fetchProviders(id: id, for: media)
            if providers.results != nil {
                isProvidersAvailable = true
                if let testItems =  providers.results?.br?.buy {
                    items.append(contentsOf: testItems)
                }
                print(providers as Any)
            }
        } catch {
            let message = """
"""
            CronicaTelemetry.shared.handleMessage(message, for: "WatchProvidersListViewModel.load()")
        }
    }
}
