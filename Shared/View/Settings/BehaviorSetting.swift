//
//  BehaviorSetting.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct BehaviorSetting: View {
    @StateObject private var store = SettingsStore.shared
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
            
            Section {
#if os(iOS)
                Toggle(isOn: $store.hapticFeedback) {
                    Text("hapticFeedbackTitle")
                }
#endif
                
            }
#if !os(tvOS)
            Section {
                Toggle(isOn: $store.markEpisodeWatchedOnTap) {
                    Text("behaviorEpisodeTitle")
                }
                Toggle(isOn: $store.preferCoverOnUpNext) {
                    Text("Prefer Series Cover instead of Episode Thumbnail on Up Next")
                }
                Toggle(isOn: $store.hideEpisodesTitles) {
                    Text("Hide Titles from Unwatched Episodes")
                    Text("To avoid potential spoilers, you can hide titles and synopsis from unwatched episodes.")
                }
                Toggle(isOn: $store.hideEpisodesThumbnails) {
                    Text("Hide Thumbnails from Unwatched Episodes")
                    Text("To avoid potential spoilers, you can hide thumbnails from unwatched episodes.")
                }
                
            }
#endif
            
            Section("Watchlist") {
#if !os(tvOS)
                Toggle("openCustomListSelectorWhenAdding", isOn: $store.openListSelectorOnAdding)
#endif
                Toggle("removeFromPinOnWatchedTitle", isOn: $store.removeFromPinOnWatched)
                Toggle("showConfirmationOnRemovingItem", isOn: $store.showRemoveConfirmation)
            }
            
#if !os(tvOS)
            shareOptions
            
#if os(macOS)
            Section {
                Toggle("Show Menu Bar App", isOn: $store.showMenuBarApp)
            }
#endif
            
            Section {
                Toggle(isOn: $store.disableSearchFilter) {
                    Text("Disable Search Filter")
                    Text("Search filter improve the search results, but has the downside of taking longer to load.")
                }
            }
#endif
            
        }
        .navigationTitle("behaviorTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var gesture: some View {
        Section {
            Picker(selection: $store.gesture) {
                ForEach(UpdateItemProperties.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Text("behaviorDoubleTapTitle")
                Text("behaviorDoubleTapSubtitle")
            }
            .tint(.secondary)
        } header: {
            Text("behaviorGestureTitle")
        }
    }
    
    private var shareOptions: some View {
        Section {
            Picker(selection: $store.shareLinkPreference) {
                ForEach(ShareLinkPreference.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Text("shareLinkPreference")
            }
            .tint(.secondary)
        } header: {
            Text("Beta")
        } footer: {
            HStack {
                Text("shareLinkPreferenceSubtitle")
                Spacer()
            }
        }
    }
    
    private var otherOptions: some View {
        Section {
#if os(iOS)
            if UIDevice.isIPhone {
                Toggle("enablePreferredLaunchScreen", isOn: $store.isPreferredLaunchScreenEnabled)
                Picker(selection: $store.preferredLaunchScreen) {
                    ForEach(Screens.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    Text("preferredLaunchScreen")
                }
                .disabled(!store.isPreferredLaunchScreenEnabled)
            }
#endif
        }
    }
    
    private var swipeGesture: some View {
        Section {
            Picker("behaviorPrimaryLeftGesture", selection: $store.primaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
            Picker("behaviorSecondaryLeftGesture", selection: $store.secondaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
            Picker("behaviorPrimaryRightGesture", selection: $store.primaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
            Picker("behaviorSecondaryRightGesture", selection: $store.secondaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
            Toggle(isOn: $store.allowFullSwipe) {
                Text("behaviorAllowFullSwipeTitle")
                Text("behaviorAllowFullSwipeSubtitle")
            }
            Button("resetToDefault") {
                store.primaryLeftSwipe = .markWatch
                store.secondaryLeftSwipe = .markFavorite
                store.primaryRightSwipe = .delete
                store.secondaryRightSwipe = .markArchive
                store.allowFullSwipe = false
            }
        } header: {
            Text("behaviorSwipeTitle")
        }
    }
    
    private var singleTapGesture: some View {
        Section {
            Toggle(isOn: $store.openInYouTube) {
                Text("behaviorYouTubeTitle")
            }
        }
    }
}

#Preview {
    BehaviorSetting()
}
