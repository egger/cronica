//
//  BehaviorSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct BehaviorSetting: View {
    @StateObject private var store = SettingsStore.shared
    var body: some View {
        Form {
            gesture
#if os(iOS)
            swipeGesture
            links
#endif
            otherOptions
#if os(iOS)
            Section {
                Toggle(isOn: $store.hapticFeedback) {
                    InformationalLabel(title: "hapticFeedbackTitle")
                }
                Toggle("removeFromPinOnWatchedTitle", isOn: $store.removeFromPinOnWatched)
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
                InformationalLabel(title: "behaviorDoubleTapTitle",
                                   subtitle: "behaviorDoubleTapSubtitle")
            }
            Toggle(isOn: $store.markEpisodeWatchedOnTap) {
                InformationalLabel(title: "behaviorEpisodeTitle")
            }
        } header: {
            Text("behaviorGestureTitle")
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
            Picker("behaviorSecondaryLeftGesture", selection: $store.secondaryLeftSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("behaviorPrimaryRightGesture", selection: $store.primaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Picker("behaviorSecondaryRightGesture", selection: $store.secondaryRightSwipe) {
                ForEach(SwipeGestureOptions.allCases) {
                    Text($0.localizableName).tag($0)
                }
            }
            Toggle(isOn: $store.allowFullSwipe) {
                InformationalLabel(title: "behaviorAllowFullSwipeTitle",
                                   subtitle: "behaviorAllowFullSwipeSubtitle")
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
    
    private var links: some View {
        Section {
            Toggle(isOn: $store.openInYouTube) {
                InformationalLabel(title: "behaviorYouTubeTitle")
            }
        }
    }
}

struct BehaviorSetting_Previews: PreviewProvider {
    static var previews: some View {
        BehaviorSetting()
            .preferredColorScheme(.light)
        BehaviorSetting()
            .preferredColorScheme(.dark)
        BehaviorSetting()
            .previewDevice("iPad Air (5th generation)")
            .previewInterfaceOrientation(.landscapeRight)
    }
}
