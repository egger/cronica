//
//  ContentRegionSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/05/23.
//

import SwiftUI

struct ContentRegionSettings: View {
    @StateObject private var store = SettingsStore.shared
#if os(macOS)
    @State private var showWatchProvidersSelector = false
#endif
    var body: some View {
        Form {
            watchProviders
            
#if os(iOS)
            Button("changeLanguage") {
                Task {
                    // Create the URL that deep links to your app's custom settings.
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }
                }
            }
#endif
        }
        .navigationTitle("contentRegionTitleSettings")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var watchProviders: some View {
        Section {
            Toggle(isOn: $store.isWatchProviderEnabled) {
                InformationalLabel(title: "behaviorWatchProvidersTitle",
                                   subtitle: "behaviorWatchProvidersSubtitle")
            }
            if store.isWatchProviderEnabled {
                Picker(selection: $store.watchRegion) {
                    ForEach(WatchProviderOption.allCases.sorted { $0.localizableTitle < $1.localizableTitle}) { region in
                        Text(region.localizableTitle)
                            .tag(region)
                    }
                } label: {
                    InformationalLabel(title: "watchRegionTitle", subtitle: "watchRegionSubtitle")
                }
                .onChange(of: store.watchRegion) { _ in
                    if !store.selectedWatchProviders.isEmpty { store.selectedWatchProviders = "" }
                }
#if os(macOS)
                .pickerStyle(.automatic)
#else
                .pickerStyle(.navigationLink)
#endif
#if os(iOS)
                NavigationLink("selectedWatchProvider", destination: WatchProviderSelectorSetting())
#elseif os(macOS)
                Button("selectedWatchProvider") {
                    showWatchProvidersSelector.toggle()
                }.buttonStyle(.link)
#endif
            }
        }
#if os(macOS)
        .sheet(isPresented: $showWatchProvidersSelector) {
            NavigationStack {
                WatchProviderSelectorSetting(showView: $showWatchProvidersSelector)
            }
            .presentationDetents([.large])
            .frame(width: 400, height: 500, alignment: .center)
        }
#endif
    }
}

struct ContentRegionSettings_Previews: PreviewProvider {
    static var previews: some View {
        ContentRegionSettings()
    }
}
