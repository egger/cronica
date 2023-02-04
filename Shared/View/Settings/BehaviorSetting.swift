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
#if os(iOS)
            Section {
                Picker(selection: $store.gesture) {
                    ForEach(DoubleTapGesture.allCases) { item in
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
                Label("behaviorGestureTitle", systemImage: "hand.tap")
            }
#endif
            
#if os(iOS)
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
                Label("behaviorSwipeTitle", systemImage: "hand.draw")
            }
#endif
            
#if os(iOS)
            Section {
                Toggle(isOn: $store.openInYouTube) {
                    InformationalLabel(title: "behaviorYouTubeTitle")
                }
            } header: {
                Label("behaviorLinkTitle", systemImage: "link")
            }
#endif
            
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
#if os(macOS)
                    .pickerStyle(.automatic)
#else
                    .pickerStyle(.navigationLink)
#endif
                }
            } header: {
                Label("contentRegionTitle", systemImage: "globe.desk")
            }
            
#if os(iOS)
            Section {
                Toggle(isOn: $store.hapticFeedback) {
                    InformationalLabel(title: "hapticFeedbackTitle")
                }
            } header: {
                Label("accessibilityTitle", systemImage: "figure.roll")
            }
#endif
        }
        .navigationTitle("behaviorTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
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
