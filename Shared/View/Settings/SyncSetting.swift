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
                Button {
                    updateItems()
                } label: {
                    if updatingItems {
                        CenterHorizontalView {
                            ProgressView()
                        }
                    } else {
                        InformationalLabel(title: "syncSettingsUpdateWatchlistTitle",
                                           subtitle: "syncSettingsUpdateWatchlistSubtitle")
                    }
                }
#if os(macOS)
                .buttonStyle(.plain)
#endif
            } header: {
                Label("syncSettingsWatchlistTitle", systemImage: "square.stack")
            }
            
            Section {
                importButton
                exportButton
            } header: {
                Label("syncSettingsItemsTitle", systemImage: "doc.on.doc")
            }
            
//            Section {
//                accountButton
//            }
        }
        .navigationTitle("syncSettingsTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var importButton: some View {
        Button {
            
        } label: {
            InformationalLabel(title: "importTitle",
                               subtitle: "importSubtitle",
                               image: "arrow.down.doc.fill")
        }
    }
    
    private var exportButton: some View {
        Button {
            
        } label: {
            InformationalLabel(title: "exportTitle",
                               subtitle: "exportSubtitle",
                               image: "arrow.up.doc.fill")
        }
    }
    
    private var accountButton: some View {
        Button {
            
        } label: {
            EmptyView()
        }
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
