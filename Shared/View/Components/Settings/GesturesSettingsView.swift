//
//  GesturesSettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/11/22.
//

import SwiftUI

struct GesturesSettingsView: View {
    @EnvironmentObject var store: SettingsStore
    @AppStorage("markEpisodeWatchedTap") private var markEpisodeWatchedOnTap = false
    @AppStorage("showPinSwipeButton") private var pinAsSwipe = false
    var body: some View {
        Form {
            Section {
                Picker(selection: $store.gesture) {
                    Text("Favorites").tag(DoubleTapGesture.favorite)
                    Text("Watched").tag(DoubleTapGesture.watched)
                } label: {
                    Text("Double Tap Gesture")
                }
                .pickerStyle(.menu)
            } header: {
                Label("Cover Image Gesture", systemImage: "hand.tap")
            } footer: {
                Text("The function is performed when double-tap the cover image.")
                    .padding(.bottom)
            }
            
            Section {
                Toggle("Tap To Mark as Watched",
                       isOn: $markEpisodeWatchedOnTap)
            } header: {
                Label("Episode Gesture", systemImage: "tv")
            } footer: {
                Text("This will mark an episode as watched on tap gesture.")
            }
            
            Section {
                Toggle("Show Pin On Swipe", isOn: $pinAsSwipe)
            } header: {
                Label("Watchlist Gesture", systemImage: "square.stack")
            }
        }
        .navigationTitle("Gestures")
    }
}

struct GesturesSettingsView_Previews: PreviewProvider {
    @StateObject private static var settings = SettingsStore()
    static var previews: some View {
        GesturesSettingsView()
            .environmentObject(settings)
    }
}
