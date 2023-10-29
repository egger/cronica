//
//  WatchProviderSelectorSetting.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 16/04/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchProviderSelectorSetting: View {
    @StateObject private var settings = SettingsStore.shared
    @State private var providers = [WatchProviderContent]()
    @State private var isLoading = true
#if os(macOS)
    @Binding var showView: Bool
#endif
    var body: some View {
        Form {
            Toggle(isOn: $settings.isSelectedWatchProviderEnabled) {
				VStack(alignment: .leading) {
					Text("selectedWatchProviderTitle")
					Text("selectedWatchProviderSubtitle")
						.foregroundColor(.secondary)
				}
            }
            if settings.isSelectedWatchProviderEnabled {
                Section {
                    List(providers, id: \.itemID) { item in
                        WatchProviderItemSelector(item: item)
                    }
					if providers.isEmpty {
						Text("Try Again Later")
							.font(.title2)
							.fontWeight(.semibold)
							.multilineTextAlignment(.center)
							.foregroundColor(.secondary)
					}
                }
                .redacted(reason: isLoading ? .placeholder : [])
            }
        }
        .navigationTitle("selectedWatchProvider")
        .onChange(of: settings.isSelectedWatchProviderEnabled) {
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
#if os(macOS)
        .formStyle(.grouped)
        .toolbar {
            Button("Done") { showView.toggle() }
        }
#endif
    }
    
    private func load() async {
        if !isLoading { return }
        if providers.isEmpty {
            do {
                let network = NetworkService.shared
                let providers = try await network.fetchWatchProviderServices(for: .movie, region: SettingsStore.shared.watchRegion.rawValue)
                var result = Set<WatchProviderContent>()
                for item in providers.results {
                    if !result.contains(where: { $0.itemId == item.itemId }) {
                        result.insert(item)
                    }
                }
                self.providers.append(contentsOf: result.sorted { $0.providerTitle < $1.providerTitle})
                withAnimation { isLoading = false }
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "WatchProviderSelectorSetting.load.failed")
            }
        }
    }
}

#Preview {
    WatchProviderSelectorSetting()
}

private struct WatchProviderItemSelector: View {
    let item: WatchProviderContent
    @StateObject private var settings = SettingsStore.shared
    @State private var isSelected = false
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? SettingsStore.shared.appTheme.color : nil)
                .fontWeight(.semibold)
                .padding(.trailing)
            WebImage(url: item.providerImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            Text(item.providerTitle)
        }
        .onTapGesture {
            if settings.selectedWatchProviders.contains(item.itemID) {
                let selected = settings.selectedWatchProviders.replacingOccurrences(of: item.itemID, with: "")
                settings.selectedWatchProviders = selected
            } else {
                settings.selectedWatchProviders.append(item.itemID)
            }
            HapticManager.shared.selectionHaptic()
        }
        .task(id: settings.selectedWatchProviders) {
            if settings.selectedWatchProviders.contains(item.itemID)  {
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
