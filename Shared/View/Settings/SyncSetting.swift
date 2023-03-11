//
//  SyncSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct SyncSetting: View {
    @State private var updatingItems = false
    @State private var isGeneratingExport = false
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
            importItems()
        } label: {
            InformationalLabel(title: "importTitle",
                               subtitle: "importSubtitle",
                               image: "arrow.down.doc.fill")
        }
    }
    
    private var exportButton: some View {
        Button {
            export()
        } label: {
            if isGeneratingExport {
                CenterHorizontalView {
                    ProgressView("generatingExportFile")
                }
            } else {
                InformationalLabel(title: "exportTitle",
                                   subtitle: "exportSubtitle",
                                   image: "arrow.up.doc.fill")
            }
        }
        .disabled(isGeneratingExport)
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
    
    private func export() {
        isGeneratingExport = true
    }
    
    private func importItems() {
        
    }
}

struct SyncSetting_Previews: PreviewProvider {
    static var previews: some View {
        SyncSetting()
    }
}
