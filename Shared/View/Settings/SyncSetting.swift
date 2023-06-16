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
    @State private var hasImported = false
    var body: some View {
        ZStack {
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
                    Text("syncSettingsWatchlistTitle")
                }
                
                Section {
#if os(iOS)
                    importButton
                    exportButton
#endif
                } footer: {
#if os(iOS)
                    Text("importExportWarning")
#endif
                }
                .sheet(isPresented: $showExportShareSheet) {
#if os(iOS)
                    CustomShareSheet(url: $exportUrl)
                        .onDisappear { deleteTempFile() }
#endif
                }
#if os(iOS)
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
#endif
                
#if os(iOS)
                Section("connectedAccounts") {
                    NavigationLink("connectedAccountTMDB", destination: TMDBAccountView())
                }
#endif
                
            }
            .navigationTitle("syncSettingsTitle")
#if os(macOS)
            .formStyle(.grouped)
#endif
            ConfirmationDialogView(showConfirmation: $hasImported, message: "importedSucceeded")
        }
    }
    
#if os(iOS)
    private var importButton: some View {
        Button {
            showFilePicker.toggle()
        } label: {
            Text("importTitle")
        }
        .disabled(hasImported)
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
#endif
    
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
    
#if os(iOS)
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
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.export.failed")
        }
    }
    
    private func deleteTempFile() {
        do {
            if let exportUrl {
                try FileManager.default.removeItem(at: exportUrl)
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.deleteTempFile.failed")
        }
    }
    
    private func importJSON(_ url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.userInfo[.context] = PersistenceController.shared.container.viewContext
            _ = try decoder.decode([WatchlistItem].self, from: jsonData)
            try context.save()
            hasImported.toggle()
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.importJSON.failed")
        }
    }
#endif
}

struct SyncSetting_Previews: PreviewProvider {
    static var previews: some View {
        SyncSetting()
    }
}

#if os(iOS)
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
#endif
