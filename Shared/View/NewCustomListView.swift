//
//  NewCustomListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 08/02/23.
//

import SwiftUI

struct NewCustomListView: View {
    @Binding var presentView: Bool
    @State private var title = ""
    @State private var showMessage = false
    @State private var shareList = false
    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section {
                        TextField("listName", text: $title)
                    } header: {
                        Label("listBasicHeader", systemImage: "pencil")
                    }
                    
                    Section {
                        Toggle("shareList", isOn: $shareList)
                    } header: {
                        Label("listShareHeader", systemImage: "person.3")
                    } footer: {
                        Text("listShareFooter")
                    }
                }
                .navigationTitle("newCustomListTitle")
                .toolbar {
                    Button("createList") {
                        save()
                        presentView = false
                    }
                    .disabled(title.isEmpty)
                }
                
                ConfirmationDialogView(showConfirmation: $showMessage,
                                       message: "newCustomListMessage",
                                       image: "checkmark.circle.fill")
            }
        }
    }
    
    private func save() {
        if title.isEmpty { return }
        let viewContext = PersistenceController.shared.container.viewContext
        let list = CustomList(context: viewContext)
        list.id = UUID()
        list.title = title
        list.creationDate = Date()
        list.updatedDate = Date()
        list.shared = shareList
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                showMessage = true
            } catch {
                let message = ""
                CronicaTelemetry.shared.handleMessage(message, for: "NewCustomListView.save()")
            }
        }
        title = ""
        presentView = false
    }
}

struct NewCustomListView_Previews: PreviewProvider {
    @State private static var presentView = true
    static var previews: some View {
        NewCustomListView(presentView: $presentView)
    }
}
