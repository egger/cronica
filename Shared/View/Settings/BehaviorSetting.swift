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

#if os(iOS)
            Section {

                Toggle(isOn: $store.hapticFeedback) {
                    Text("Haptic Feedback")
                }
            }
#endif
#if os(iOS) || os(macOS)
            Section {
                Toggle(isOn: $store.markEpisodeWatchedOnTap) {
                    Text("Tap To Mark Episode as Watched")
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
#if os(iOS) || os(macOS)
                Toggle("Open List Selector when adding an item", isOn: $store.openListSelectorOnAdding)
#endif
                Toggle("Remove From Pin when item is  marked as watched", isOn: $store.removeFromPinOnWatched)
                Toggle("Show Remove Confirmation", isOn: $store.showRemoveConfirmation)
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
        .navigationTitle("Behavior")
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
                Text("Double Tap On Cover/Poster")
                Text("Choose what function to perform when double tap the cover/poster image.")
            }
            .tint(.secondary)
        } header: {
            Text("Gestures")
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
            .tint(.secondary)
        } header: {
            Text("Beta")
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
                Picker(selection: $store.preferredLaunchScreen) {
                    ForEach(Screens.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    Text("Preferred Launch Screen")
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
            .tint(.secondary)
            Picker("Secondary Left Gesture", selection: $store.secondaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
            Picker("Primary Right Gesture", selection: $store.primaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
            Picker("Secondary Right Gesture", selection: $store.secondaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            .tint(.secondary)
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
}

#Preview {
    BehaviorSetting()
}
