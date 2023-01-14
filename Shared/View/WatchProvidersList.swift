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
    
    func openLink() {
        
    }
}

struct WatchProviderItem: View {
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
    @Published var items = [WatchProviderContent]()
    @Published var link: String?
    private var isLoaded = false
    
    @MainActor
    func load(id: ItemContent.ID, media: MediaType) async {
        do {
            if Task.isCancelled { return }
            if isLoaded { return }
            let providers = try await NetworkService.shared.fetchProviders(id: id, for: media)
            
            if let results = providers.results {
                withAnimation { isProvidersAvailable = true }
                link = results.br?.link
                var content = [WatchProviderContent]()
                if let flatrate = results.br?.flatrate {
                    content.append(contentsOf: flatrate.sorted { $0.listPriority < $1.listPriority })
                }
                if let buy =  results.br?.buy {
                    content.append(contentsOf: buy.sorted { $0.listPriority < $1.listPriority })
                }
                if let free = results.br?.free {
                    content.append(contentsOf: free.sorted { $0.listPriority < $1.listPriority })
                }
                items.append(contentsOf: content)
            }
            isLoaded = true
        } catch {
            let message = """
"""
            CronicaTelemetry.shared.handleMessage(message, for: "WatchProvidersListViewModel.load()")
        }
    }
}


enum WatchProviderOption: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case br, us
    var localizableTitle: String {
        switch self {
        case .br:
            return NSLocalizedString("watchProviderBr", comment: "")
        case .us:
            return NSLocalizedString("watchProviderUs", comment: "")
        }
    }
}
