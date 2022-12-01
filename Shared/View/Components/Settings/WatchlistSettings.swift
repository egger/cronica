//
//  WatchlistSettings.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI

struct WatchlistSettings: View {
    @AppStorage("showGenreOnWatchlist") private var showGenre = false
    @State private var updatingItems = false
    var body: some View {
        Form {
            Section {
                Button(action: {
                    updateItems()
                }, label: {
                    if updatingItems {
                        CenterHorizontalView {
                            ProgressView()
                        }
                    } else {
                        Text("Update Items")
                    }
                })
            } header: {
                Label("Sync", systemImage: "arrow.2.circlepath")
            } footer: {
                Text("'Update Items' will update your items with new information available on TMDb, if available.")
                    .padding(.bottom)
            }
#if os(iOS)
            Toggle("Show Genre on Watchlist", isOn: $showGenre)
#endif
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
        .navigationTitle("Watchlist")
    }
    
    private func updateItems() {
        Task {
            let background = BackgroundManager()
            withAnimation {
                self.updatingItems.toggle()
            }
            await background.handleAppRefreshContent()
            withAnimation {
                self.updatingItems.toggle()
            }
        }
    }
}

struct WatchlistSettings_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistSettings()
    }
}
