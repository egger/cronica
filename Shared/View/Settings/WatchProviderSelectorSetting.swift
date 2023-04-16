//
//  WatchProviderSelectorSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchProviderSelectorSetting: View {
    @StateObject private var settings = SettingsStore.shared
    @State private var providers = [WatchProviderContent]()
    @State private var isLoading = true
    var body: some View {
        Form {
            Toggle(isOn: $settings.isSelectedWatchProviderEnabled) {
                InformationalLabel(title: "selectedWatchProviderTitle",
                                   subtitle: "selectedWatchProviderSubtitle")
            }
            if settings.isSelectedWatchProviderEnabled {
                Section {
                    List(providers, id: \.self) { item in
                        WatchProviderItemSelector(item: item)
                    }
                }
                .redacted(reason: isLoading ? .placeholder : [])
            }
        }
        .navigationTitle("selectedWatchProvider")
        .onChange(of: settings.isSelectedWatchProviderEnabled) { _ in 
            if settings.isSelectedWatchProviderEnabled {
                Task { await load() }
            } else {
                settings.selectedWatchProviders = ""
            }
        }
        .onAppear {
            if settings.isWatchProviderEnabled {
                Task { await load() }
            }
        }
    }
    
    private func load() async {
        if !isLoading { return }
        if providers.isEmpty {
            do {
                let network = NetworkService.shared
                let moviesProviders = try await network.fetchWatchProviderServices(for: .movie, region: SettingsStore.shared.watchRegion.rawValue)
                let showProviders = try await network.fetchWatchProviderServices(for: .tvShow, region: SettingsStore.shared.watchRegion.rawValue)
                var result = [WatchProviderContent]()
                let combined = moviesProviders.results + showProviders.results
                for item in combined {
                    if !result.contains(where: { $0.itemId == item.itemId }) {
                        result.append(item)
                    }
                }
                var set = Set<WatchProviderContent>()
                for item in combined { set.insert(item) }
                providers.append(contentsOf: set.sorted { $0.providerTitle < $1.providerTitle})
                withAnimation { isLoading = false }
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "WatchProviderSelectorSetting.load.failed")
            }
        }
    }
}

struct WatchProviderSelectorSetting_Previews: PreviewProvider {
    static var previews: some View {
        WatchProviderSelectorSetting()
    }
}

private struct WatchProviderItemSelector: View {
    let item: WatchProviderContent
    @StateObject private var settings = SettingsStore.shared
    @State private var isSelected = false
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? SettingsStore.shared.appTheme.color : nil)
                .padding(.trailing)
            WebImage(url: item.providerImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(item.providerTitle)
        }
        .onTapGesture {
            if settings.selectedWatchProviders.contains("@\(item.itemId)-\(item.providerTitle)") {
                let selected = settings.selectedWatchProviders.replacingOccurrences(of: "@\(item.itemId)-\(item.providerTitle)", with: "")
                settings.selectedWatchProviders = selected
            } else {
                settings.selectedWatchProviders.append("@\(item.itemId)-\(item.providerTitle)")
            }
            print(settings.selectedWatchProviders)
        }
        .task(id: settings.selectedWatchProviders) {
            if settings.selectedWatchProviders.contains("@\(item.itemId)-\(item.providerTitle)")  {
                if !isSelected {
                    withAnimation { isSelected = true }
                }
            } else {
                if isSelected {
                    withAnimation { isSelected = false }
                }
            }
        }
    }
}
