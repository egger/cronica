//
//  BehaviorSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct BehaviorSetting: View {
    @StateObject var store = SettingsStore.shared
    @AppStorage("openInYouTube") private var openInYouTube = false
    @AppStorage("markEpisodeWatchedTap") private var markEpisodeWatchedOnTap = false
    @AppStorage("enableHapticFeedback") private var hapticFeedback = true
    @AppStorage("enableWatchProviders") private var isWatchProviderEnabled = true
    @AppStorage("selectedWatchProviderRegion") private var watchRegion: WatchProviderOption = .us
    var body: some View {
        Form {
            Section {
                Picker(selection: $store.gesture) {
                    ForEach(DoubleTapGesture.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "behaviorDoubleTapTitle",
                                        subtitle: "behaviorDoubleTapSubtitle")
                }
                Toggle(isOn: $markEpisodeWatchedOnTap) {
                    InformationalLabel(title: "behaviorEpisodeTitle")
                }
            } header: {
                Label("behaviorGestureTitle", systemImage: "hand.tap")
            }
            
            Section {
                Toggle(isOn: $openInYouTube) {
                    InformationalLabel(title: "behaviorYouTubeTitle")
                }
//                Picker(selection: $store.preferredShareLink) {
//                    ForEach(PreferredShareLink.allCases) { item in
//                        Text(item.localizableNameTitle).tag(item)
//                    }
//                } label: {
//                    InformationalLabel(title: "behaviorPreferredShareLinkTitle",
//                                        subtitle: "behaviorPreferredShareLinkSubtitle")
//                }
            } header: {
                Label("behaviorLinkTitle", systemImage: "link")
            }
            
            Section {
                Toggle(isOn: $isWatchProviderEnabled) {
                    InformationalLabel(title: "behaviorWatchProvidersTitle",
                                       subtitle: "behaviorWatchProvidersSubtitle")
                }
                if isWatchProviderEnabled {
                    Picker(selection: $watchRegion) {
                        ForEach(WatchProviderOption.allCases.sorted { $0.localizableTitle < $1.localizableTitle}) { region in
                            Text(region.localizableTitle)
                                .tag(region)
                        }
                    } label: {
                        InformationalLabel(title: "watchRegionTitle", subtitle: "watchRegionSubtitle")
                    }
                }
            } header: {
                Label("contentRegionTitle", systemImage: "globe.desk")
            }
            
            Section {
                Toggle(isOn: $hapticFeedback) {
                    InformationalLabel(title: "hapticFeedbackTitle", subtitle: "hapticFeedbackSubtitle")
                }
            } header: {
                Label("accessibilityTitle", systemImage: "figure.roll")
            }
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
    }
}
