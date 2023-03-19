//
//  SyncSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI
import CoreData

struct SyncSetting: View {
    @State private var updatingItems = false
    @State private var isGeneratingExport = false
    @State private var showExportShareSheet = false
    @State private var showFilePicker = false
    @State private var exportUrl: URL?
    @Environment(\.managedObjectContext) private var context
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
            }
            .sheet(isPresented: $showExportShareSheet) {
                CustomShareSheet(url: $exportUrl)
                    .onDisappear { deleteTempFile() }
            }
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let success):
                    if success.startAccessingSecurityScopedResource() {
                        importJSON(success)
                    }
                case .failure(let failure):
                    CronicaTelemetry.shared.handleMessage(failure.localizedDescription, for: "SyncSettings.fileImporter")
                }
            }
            
        }
        .navigationTitle("syncSettingsTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var importButton: some View {
        Button {
            showFilePicker.toggle()
        } label: {
            Text("importTitle")
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
                Text("exportTitle")
            }
        }
        .disabled(isGeneratingExport)
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
        do {
            isGeneratingExport = true
            if let entityName = WatchlistItem.entity().name {
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let items = try context.fetch(request).compactMap {
                    $0 as? WatchlistItem
                }
                let jsonData = try JSONEncoder().encode(items)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    if let tempUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                        let pathUrl = tempUrl.appending(component: "CronicaExport \(Date().formatted(date: .abbreviated, time: .omitted)).json")
                        try jsonString.write(to: pathUrl, atomically: true, encoding: .utf8)
                        exportUrl = pathUrl
                        showExportShareSheet.toggle()
                    }
                }
            }
            isGeneratingExport = false
        } catch {
            isGeneratingExport = false
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.export()")
        }
    }
    
    private func deleteTempFile() {
        do {
            if let exportUrl {
                try FileManager.default.removeItem(at: exportUrl)
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.deleteTempFile()")
        }
    }
    
    private func importJSON(_ url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.userInfo[.context] = context
            let items = try decoder.decode([WatchlistItem].self, from: jsonData)
            print(items)
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.importJSON")
        }
    }
}

struct SyncSetting_Previews: PreviewProvider {
    static var previews: some View {
        SyncSetting()
    }
}

struct CustomShareSheet: UIViewControllerRepresentable {
    @Binding var url: URL?
    func makeUIViewController(context: Context) -> some UIViewController {
        if let url {
            return UIActivityViewController(activityItems: [url], applicationActivities: nil)
        }
        return UIActivityViewController(activityItems: [], applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
