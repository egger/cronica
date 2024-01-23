//
//  RegionContentSettings.swift
//  Cronica (iOS)
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
                    VStack(alignment: .leading) {
                        Text("Region")
                        Text("The app will adapt watch providers based on your region")
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: store.watchRegion) { _ in 
                    if !store.selectedWatchProviders.isEmpty { store.selectedWatchProviders = "" }
                }
#if os(macOS)
                .pickerStyle(.automatic)
#elseif os(visionOS)
                .pickerStyle(.menu)
                #else
                .pickerStyle(.navigationLink)
#endif
            }
#if !os(tvOS)
            Section {
                Toggle(isOn: $store.isWatchProviderEnabled) {
					Text("Watch Providers")
					Text("See in what platforms the content is available on.")
                }
#if os(iOS) || os(visionOS)
                NavigationLink("Streaming Services", destination: WatchProviderSelectorSetting())
#elseif os(macOS)
                Button("Streaming Services") {
                    showWatchProvidersSelector.toggle()
                }
                .sheet(isPresented: $showWatchProvidersSelector) {
                    NavigationStack {
                        WatchProviderSelectorSetting(showView: $showWatchProvidersSelector)
                    }
                    .frame(width: 400, height: 500, alignment: .center)
                }
#endif
                
            }
#endif
#if os(iOS)
            languageButton
#endif
        }
        .navigationTitle("Region")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
#if os(iOS)
    private var languageButton: some View {
        Button("Change app language") {
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

#Preview {
    RegionContentSettings()
}
