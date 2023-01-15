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
    @State private var showConfirmation = false
    @AppStorage("alwaysShowConfirmationWatchProvider") private var isConfirmationEnabled = true
    var body: some View {
        VStack {
            if viewModel.isProvidersAvailable && !viewModel.items.isEmpty {
                TitleView(title: "watchProviderTitleList",
                          subtitle: "",
                          image: "rectangle.stack.badge.play.fill",
                          showChevron: false)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.items, id: \.self) { item in
                            Button(action: {
                                if isConfirmationEnabled {
                                    showConfirmation.toggle()
                                } else {
                                    openLink()
                                }
                            }, label: {
                                WatchProviderItem(item: item)
                            })
                            .buttonStyle(.plain)
                            .padding(.leading, item.self == viewModel.items.first!.self ? 16 : 4)
                            .padding(.leading, item.self == viewModel.items.last!.self ? 16 : 4)
                        }
                    }
                    .padding([.top, .bottom], 8)
                }
            }
        }
        .task {
            await viewModel.load(id: id, media: type)
        }
        .alert("openWatchProviderTitle", isPresented: $showConfirmation) {
            Button("confirmOpenWatchProvider") { openLink() }
            Button("confirmOpenDontAskAgainProvider") {
                isConfirmationEnabled = false
                openLink()
            }
            Button("cancelOpenWatchProvider") { showConfirmation = false }
        }
    }
    
    private func openLink() {
        if let link = viewModel.link {
#if os(macOS)
            NSWorkspace.shared.open(link)
#else
            UIApplication.shared.open(link)
#endif
        }
    }
}

private struct WatchProviderItem: View {
    let item: WatchProviderContent
    var body: some View {
        VStack(alignment: .leading) {
            WebImage(url: item.providerImage)
                .resizable()
                .placeholder {
                    VStack {
                        ProgressView()
                            .frame(width: 80, height: 80, alignment: .center)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .applyHoverEffect()
            Text(item.providerTitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .padding(.leading)
        }
        .frame(width: 80, height: 100, alignment: .center)
    }
}

struct WatchProvidersList_Previews: PreviewProvider {
    private static let example = ItemContent.previewContent
    static var previews: some View {
        WatchProvidersList(id: example.id, type: example.itemContentMedia)
    }
}
