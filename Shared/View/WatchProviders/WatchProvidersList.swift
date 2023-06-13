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
    @AppStorage("enableWatchProviders") private var isWatchProviderEnabled = true
    var body: some View {
        VStack {
            if viewModel.isProvidersAvailable && isWatchProviderEnabled {
                TitleView(title: "watchProviderTitleList",
                          subtitle: "justWatchSubtitle",
                          showChevron: false)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(viewModel.items, id: \.self) { item in
                            Button {
                                if isConfirmationEnabled {
                                    showConfirmation.toggle()
                                } else {
                                    openLink()
                                }
                            } label: {
                                WatchProviderItem(item: item)
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, item.self == viewModel.items.first!.self ? 16 : 0)
                            .padding(.trailing, item.self == viewModel.items.last!.self ? 16 : 0)
                            .padding(.horizontal, 6)
                            .padding(.top, 8)
#if os(iOS)
                            .hoverEffect()
#endif
                        }
                        .padding(.bottom)
                    }
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
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: DrawingConstants.imageWidth,
                       height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                .shadow(radius: 2.5)
                .applyHoverEffect()
            Text(item.providerTitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(DrawingConstants.lineLimits)
                .padding(.leading, 2)
        }
        .frame(width: DrawingConstants.imageWidth)
    }
}
private struct DrawingConstants {
    static let imageRadius: CGFloat = 8
    static let imageWidth: CGFloat = 60
    static let imageHeight: CGFloat = 60
    static let lineLimits: Int = 1
}

struct WatchProvidersList_Previews: PreviewProvider {
    static var previews: some View {
        WatchProvidersList(id: ItemContent.example.id, type: .movie)
    }
}
