//
//  SyncSetting.swift
//  Cronica (iOS)
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
							VStack(alignment: .leading) {
								Text("Update Items")
								Text("Update items with new information, if available on TMDb")
									.foregroundColor(.secondary)
							}
                        }
                    }
#if os(macOS)
                    .buttonStyle(.plain)
#endif
                } header: {
                    Text("Watchlist")
                }
                
                Section {
#if os(iOS)
                    importButton
                    exportButton
#endif
                } footer: {
#if os(iOS)
                    Text("Export/Import is in beta, only use it to export your data or to import if you're switching your iCloud account, there's no logic at the moment to avoid duplication. A future update will provide a better experience for all users.")
#endif
                }
                .sheet(isPresented: $showExportShareSheet) {
#if os(iOS)
                    CustomShareSheet(url: $exportUrl)
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
                //TMDBAccountView()
#endif
                
            }
            .navigationTitle("Sync")
#if os(macOS)
            .formStyle(.grouped)
#endif
        }
    }
    
#if os(iOS)
    private var importButton: some View {
        Button {
            showFilePicker.toggle()
        } label: {
            Text("Import")
        }
        .disabled(hasImported)
    }
    
    private var exportButton: some View {
        Button {
            export()
        } label: {
            if isGeneratingExport {
                CenterHorizontalView {
                    ProgressView("Generating File")
                }
            } else {
                Text("Export")
            }
        }
        .disabled(isGeneratingExport)
    }
#endif
}

extension SyncSetting {
    @MainActor
    private func updateItems() {
        Task {
            let background = BackgroundManager.shared
            await MainActor.run {
                withAnimation {
                    self.updatingItems.toggle()
                }
            }
            await background.handleWatchingContentRefresh()
            await background.handleUpcomingContentRefresh()
            await background.handleAppRefreshMaintenance()
            await MainActor.run {
                withAnimation {
                    self.updatingItems.toggle()
                }
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
    
    private func importJSON(_ url: URL) {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.userInfo[.context] = PersistenceController.shared.container.viewContext
            _ = try decoder.decode([WatchlistItem].self, from: jsonData)
            try context.save()
            hasImported.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    hasImported = false
                }
            }
        } catch {
            CronicaTelemetry.shared.handleMessage(error.localizedDescription, for: "SyncSettings.importJSON.failed")
        }
    }
#endif
}

#Preview {
    SyncSetting()
}

#if os(iOS)
private struct CustomShareSheet: UIViewControllerRepresentable {
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
