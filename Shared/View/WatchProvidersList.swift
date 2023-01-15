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

//struct WatchProvidersList_Previews: PreviewProvider {
//    static var previews: some View {
//        WatchProvidersList()
//    }
//}

class WatchProvidersListViewModel: ObservableObject {
    @Published var isProvidersAvailable = false
    @Published var items = [WatchProviderContent]()
    @Published var link: URL?
    private var isLoaded = false
    @AppStorage("enableWatchProviders") private var isWatchProviderEnabled = true
    @AppStorage("selectedWatchProviderRegion") private var watchRegion: WatchProviderOption = .us
    @AppStorage("firstLocaleCheck") private var firstCheck = false
    
    private func checkLocale() {
        if firstCheck { return }
        let userLocale = Utilities.userRegion
        let providerRegions = WatchProviderOption.allCases
        for region in providerRegions {
            if userLocale.lowercased() == region.rawValue.lowercased() {
                watchRegion = region
            }
        }
        firstCheck = true
    }
    
    @MainActor
    func load(id: ItemContent.ID, media: MediaType) async {
        do {
            if !firstCheck { checkLocale() }
            if Task.isCancelled { return }
            if isLoaded { return }
            let providers = try await NetworkService.shared.fetchProviders(id: id, for: media)
            if let results = providers.results {
                var regionContent: ProviderItem?
                switch watchRegion {
                case .br:
                    regionContent = results.br
                case .us:
                    regionContent = results.us
                case .ae:
                    regionContent = results.ae
                case .ar:
                    regionContent = results.ar
                case .at:
                    regionContent = results.at
                case .au:
                    regionContent = results.au
                case .be:
                    regionContent = results.be
                case .bg:
                    regionContent = results.bg
                case .ca:
                    regionContent = results.ca
                case .ch:
                    regionContent = results.ch
                case .cz:
                    regionContent = results.cz
                case .de:
                    regionContent = results.de
                case .dk:
                    regionContent = results.dk
                case .ee:
                    regionContent = results.ee
                case .es:
                    regionContent = results.es
                case .fi:
                    regionContent = results.fi
                case .fr:
                    regionContent = results.fr
                case .gb:
                    regionContent = results.gb
                case .hk:
                    regionContent = results.hk
                case .hr:
                    regionContent = results.hr
                case .hu:
                    regionContent = results.hu
                case .id:
                    regionContent = results.id
                case .ie:
                    regionContent = results.ie
                case .india:
                    regionContent = results.resultsIN
                case .it:
                    regionContent = results.it
                case .jp:
                    regionContent = results.jp
                case .kr:
                    regionContent = results.kr
                case .lt:
                    regionContent = results.lt
                case .mx:
                    regionContent = results.mx
                case .nl:
                    regionContent = results.nl
                case .no:
                    regionContent = results.no
                case .nz:
                    regionContent = results.nz
                case .ph:
                    regionContent = results.ph
                case .pl:
                    regionContent = results.pl
                case .pt:
                    regionContent = results.pt
                case .rs:
                    regionContent = results.rs
                case .se:
                    regionContent = results.se
                case .sk:
                    regionContent = results.sk
                case .tr:
                    regionContent = results.tr
                case .za:
                    regionContent = results.za
                }
                link = regionContent?.itemLink
                var content = [WatchProviderContent]()
                if let flatrate = regionContent?.flatrate {
                    content.append(contentsOf: flatrate)
                }
                if let buy =  regionContent?.buy {
                    content.append(contentsOf: buy)
                }
                if let free = regionContent?.free {
                    content.append(contentsOf: free)
                }
                items.append(contentsOf: content.sorted { $0.listPriority < $1.listPriority })
                withAnimation { isProvidersAvailable = true }
            }
            isLoaded = true
        } catch {
            let message = """
"""
            CronicaTelemetry.shared.handleMessage(message, for: "WatchProvidersListViewModel.load()")
        }
    }
}
