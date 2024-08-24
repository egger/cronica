//
//  BehaviorSetting.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI
import Nuke

struct BehaviorSetting: View {
    @StateObject private var store = SettingsStore.shared
    @State private var cacheSizeMB: Double = 0.0
    var body: some View {
        Form {
#if !os(tvOS)
            gesture
#endif
#if os(iOS)
            swipeGesture
            singleTapGesture
#endif
            otherOptions
            
#if os(iOS)
            Section {
                Toggle(isOn: $store.hapticFeedback) {
                    Text("Haptic Feedback")
                }
            }
#endif
            
#if !os(tvOS)
            shareOptions
            
            Section {
                Toggle(isOn: $store.disableSearchFilter) {
                    Text("Disable Search Filter")
                    Text("Search filter improve the search results, but has the downside of taking longer to load.")
                }
            }
#endif
            
            Section {
                Button {
                    clearCache()
                } label: {
                    VStack(alignment: .leading) {
                        Text("Clear Cache")
                            .foregroundStyle(.red)
                        Text("Cache Size: \(String(format: "%.2f", cacheSizeMB)) MB")
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
            
        }
        .navigationTitle("Behavior")
#if os(macOS)
        .formStyle(.grouped)
#endif
        .onAppear {
            updateCacheSize()
        }
    }
    
    private var gesture: some View {
        Section("Gestures") {
            Picker(selection: $store.gesture) {
                ForEach(UpdateItemProperties.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Text("Double Tap On Cover/Poster")
                Text("Choose what function to perform when double tap the cover/poster image.")
            }
        }
    }
    
    private var shareOptions: some View {
        Section {
            Picker(selection: $store.shareLinkPreference) {
                ForEach(ShareLinkPreference.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Text("Sharable Link")
            }
        } header: {
#if !os(macOS)
            Text("Beta")
#endif
        } footer: {
            HStack {
                Text("You can choose to share using a Cronica link that will allow you to open the application.\nPlease note that not all content can be shared with a Cronica link, the application will always use TMDB links if necessary.")
                Spacer()
            }
        }
    }
    
    private var otherOptions: some View {
        Section {
#if os(iOS)
            if UIDevice.isIPhone {
                Toggle("Enable Preferred Launch Screen", isOn: $store.isPreferredLaunchScreenEnabled)
                Picker("Preferred Launch Screen", selection: $store.preferredLaunchScreen) {
                    ForEach(Screens.allCases) { item in
                        if item != .notifications, item != .settings {
                            Text(item.title).tag(item)
                        }
                    }
                }
                .disabled(!store.isPreferredLaunchScreenEnabled)
            }
#endif
        }
    }
    
    private var swipeGesture: some View {
        Section {
            Picker("Primary Left Gesture", selection: $store.primaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("Secondary Left Gesture", selection: $store.secondaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("Primary Right Gesture", selection: $store.primaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("Secondary Right Gesture", selection: $store.secondaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Toggle(isOn: $store.allowFullSwipe) {
                Text("Allow Full Swipe")
                Text("Full Swipe will activate the primary action")
            }
            Button("Reset to Default") {
                store.primaryLeftSwipe = .markWatch
                store.secondaryLeftSwipe = .markFavorite
                store.primaryRightSwipe = .delete
                store.secondaryRightSwipe = .markArchive
                store.allowFullSwipe = false
            }
        } header: {
            Text("Swipe Gestures")
        }
    }
    
    private var singleTapGesture: some View {
        Section {
            Toggle(isOn: $store.openInYouTube) {
                Text("Open Trailers in YouTube")
            }
        }
    }
    
    private func clearCache() {
        DataLoader.sharedUrlCache.removeAllCachedResponses()
        ImageCache.shared.removeAll()
        updateCacheSize()
    }
    
    private func updateCacheSize() {
        let cache = ImageCache.shared
        let totalSizeInBytes = cache.totalCost // Total cost is in bytes
        print("total item in Nuke cache: \(totalSizeInBytes)")
        
        // Convert bytes to megabytes
        let sizeInMB = Double(totalSizeInBytes) / (1024 * 1024)
        cacheSizeMB = sizeInMB
    }
}

#Preview {
    BehaviorSetting()
}
