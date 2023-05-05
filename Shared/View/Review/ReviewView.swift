//
//  WatchlistItemNoteView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/23.
//

import SwiftUI

struct ReviewView: View {
    let id: String
    @State var item: WatchlistItem?
    @Binding var showView: Bool
    @State private var note = String()
    @State private var rating = 0
    @State private var isLoading = true
    @State private var canSave = false
    let persistence = PersistenceController.shared
    var body: some View {
        Form {
            if isLoading {
                Section {
                    CenterHorizontalView { ProgressView().padding() }
                }
            } else {
                if let item {
                    Section("About") { Text("reviewOf \(item.itemTitle)") }
                    Section("Rating") {
                        CenterHorizontalView {
                            RatingView(rating: $rating)
                        }
                    }
                    #if os(iOS) || os(macOS)
                    Section("Notes") {
                        TextEditor(text: $note)
                            .frame(minHeight: 150)
                    }
                    #endif
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle("reviewTitle")
        .onAppear { load() }
        .onChange(of: rating) { newValue in
            guard let item else { return }
            if newValue != Int(item.userRating) {
                if !canSave { canSave = true }
            }
        }
        .onChange(of: note) { newValue in
            guard let item else { return }
            if newValue != item.userNotes {
                if !canSave { canSave = true }
            }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarLeading) { doneButton }
            ToolbarItem(placement: .navigationBarTrailing) { saveButton }
#elseif os(macOS)
            ToolbarItem(placement: .confirmationAction) { saveButton }
            ToolbarItem(placement: .cancellationAction) { doneButton }
#endif
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private func load() {
        let item = try? persistence.fetch(for: id)
        guard let item else {
            return
        }
        if note.isEmpty { note = item.userNotes }
        rating = Int(item.userRating)
        self.item = item
        withAnimation { isLoading = false }
    }
    
    private var doneButton: some View {
        Button("Cancel", action: dismiss)
    }
    
    private var saveButton: some View {
        Button("Save", action: save).disabled(!canSave)
    }
    
    private func save() {
        guard let item else { return }
        persistence.updateReview(for: item, rating: rating, notes: note)
        dismiss()
    }
    
    private func dismiss() { showView.toggle() }
}

struct WatchlistItemNoteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ReviewView(id: ItemContent.example.itemNotificationID, showView: .constant(true))
        }
    }
}
