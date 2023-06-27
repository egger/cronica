//
//  WatchProvidersListViewModel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 15/01/23.
//

import SwiftUI

class WatchProvidersListViewModel: ObservableObject {
    @Published var isProvidersAvailable = false
    @Published var items = [WatchProviderContent]()
    @Published var link: URL?
    private var isLoaded = false
    @AppStorage("enableWatchProviders") private var isWatchProviderEnabled = true
    @AppStorage("firstLocaleCheck") private var firstCheck = false
    private var settings = SettingsStore.shared
    
    private func checkLocale() {
        if firstCheck { return }
        let userLocale = Locale.userRegion
        let providerRegions = AppContentRegion.allCases
        for region in providerRegions {
            if userLocale.lowercased() == region.rawValue.lowercased() {
                settings.watchRegion = region
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
            guard let results = providers.results else { return }
            let regionContent = filterByRegion(results)
            if let regionContent {
                link = regionContent.itemLink
                var content = [WatchProviderContent]()
                if let flatrate = regionContent.flatrate {
                    if settings.isSelectedWatchProviderEnabled {
                        for item in flatrate {
                            if settings.selectedWatchProviders.contains(item.itemID) {
                                content.append(item)
                            }
                        }
                    } else {
                        content.append(contentsOf: flatrate)
                    }
                    
                }
                if let buy =  regionContent.buy {
                    if settings.isSelectedWatchProviderEnabled {
                        for item in buy {
                            if settings.selectedWatchProviders.contains(item.itemID) {
                                content.append(item)
                            }
                        }
                    } else {
                        content.append(contentsOf: buy)
                    }
                    
                }
                
                items.append(contentsOf: content.sorted { $0.listPriority < $1.listPriority })
                
            }
            if !items.isEmpty {
                withAnimation { isProvidersAvailable = true }
            }
            isLoaded = true
        } catch {
            if Task.isCancelled { return }
            let message = """
Can't load the provider for \(id) with media type of \(media.rawValue).
Actual region: \(Locale.userRegion), selected region: \(settings.watchRegion.rawValue).
Error: \(error.localizedDescription)
"""
            CronicaTelemetry.shared.handleMessage(message, for: "WatchProvidersListViewModel.load()")
        }
    }
    
    private func filterByRegion(_ results: Results) -> ProviderItem? {
        var regionContent: ProviderItem?
        switch settings.watchRegion {
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
        return regionContent
    }
}
