//
//  RegionContentSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 14/06/23.
//

import SwiftUI

struct RegionContentSettings: View {
    @StateObject private var store = SettingsStore.shared
#if os(macOS)
    @State private var showWatchProvidersSelector = false
#endif
    var body: some View {
        Form {
            
            Section {
                Picker(selection: $store.watchRegion) {
                    ForEach(AppContentRegion.allCases.sorted { $0.localizableTitle < $1.localizableTitle}) { region in
                        Text(region.localizableTitle)
                            .tag(region)
                    }
                } label: {
                    InformationalLabel(title: "appRegionTitle", subtitle: "appRegionSubtitle")
                }
                .onChange(of: store.watchRegion) { _ in
                    if !store.selectedWatchProviders.isEmpty { store.selectedWatchProviders = "" }
                }
#if os(macOS)
                .pickerStyle(.automatic)
#else
                .pickerStyle(.navigationLink)
#endif
            }
#if !os(tvOS)
            Section {
                Toggle(isOn: $store.isWatchProviderEnabled) {
                    InformationalLabel(title: "behaviorWatchProvidersTitle",
                                       subtitle: "behaviorWatchProvidersSubtitle")
                }
#if os(iOS)
                NavigationLink("selectedWatchProvider", destination: WatchProviderSelectorSetting())
#elseif os(macOS)
                Button("selectedWatchProvider") {
                    showWatchProvidersSelector.toggle()
                }
                .sheet(isPresented: $showWatchProvidersSelector) {
                    NavigationStack {
                        WatchProviderSelectorSetting(showView: $showWatchProvidersSelector)
                    }
                    .presentationDetents([.large])
                    .frame(width: 400, height: 500, alignment: .center)
                }
#endif
                
            }
#endif
#if os(iOS)
            languageButton
#endif
        }
        .navigationTitle("settingsRegionContentTitle")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
#if os(iOS)
    private var languageButton: some View {
        Button("changeLanguage") {
            Task {
                // Create the URL that deep links to your app's custom settings.
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    // Ask the system to open that URL.
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
#endif
}

//@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
//#Preview {
//    RegionContentSettings()
//}
