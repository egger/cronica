//
//  SyncSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct SyncSetting: View {
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
                        InformationalLabel(title: "syncSettingsUpdateWatchlistTitle",
                                            subtitle: "syncSettingsUpdateWatchlistSubtitle")
                    }
                })
                #if os(macOS)
                .buttonStyle(.plain)
                #endif
            } header: {
                Label("syncSettingsWatchlistTitle", systemImage: "square.stack")
            }
        }
        .navigationTitle("syncSettingsTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func updateItems() {
        Task {
            let background = BackgroundManager()
            withAnimation {
                self.updatingItems.toggle()
            }
            await background.handleAppRefreshContent()
            await background.handleAppRefreshMaintenance()
            withAnimation {
                self.updatingItems.toggle()
            }
        }
    }
}

struct SyncSetting_Previews: PreviewProvider {
    static var previews: some View {
        SyncSetting()
    }
}
