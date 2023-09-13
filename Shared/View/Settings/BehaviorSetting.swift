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
            
            Section("Watchlist") {
                Toggle("openCustomListSelectorWhenAdding", isOn: $store.openListSelectorOnAdding)
                Toggle("removeFromPinOnWatchedTitle", isOn: $store.removeFromPinOnWatched)
                Toggle("showConfirmationOnRemovingItem", isOn: $store.showRemoveConfirmation)
            }
            
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
            
            Section {
                Toggle(isOn: $store.disableSearchFilter) {
                    Text("Disable Search Filter")
                    Text("Search filter improve the search results, but has the downside of taking longer to load.")
                }
            }
			
#if os(macOS)
//			Section {
//				Toggle("quitWhenClosingApp", isOn: $store.quitApp)
//			}
//			.hidden()
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
            Toggle(isOn: $store.markEpisodeWatchedOnTap) {
                Text("behaviorEpisodeTitle")
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
