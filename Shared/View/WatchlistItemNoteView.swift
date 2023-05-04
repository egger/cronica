//
//  WatchlistItemNoteView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/23.
//

import SwiftUI

struct WatchlistItemNoteView: View {
    let id: String
    @State var item: WatchlistItem?
    @Binding var showView: Bool
    @State private var note = String()
    @State private var rating = 0
    @State private var isLoading = true
    let persistence = PersistenceController.shared
    var body: some View {
        Form {
            if isLoading {
                ProgressView()
            } else {
                if let item {
                    Text("reviewOf \(item.itemTitle)")
                    Section {
                        CenterHorizontalView {
                            RatingView(rating: $rating)
                        }
                    } header: {
                        Text("Rating")
#if os(macOS)
                            .foregroundColor(.secondary)
                            .font(.callout)
#endif
                    }
                    Section {
#if os(iOS) || os(macOS)
                        TextEditor(text: $note)
                            .frame(minHeight: 150)
#endif
                    } header: {
                        Text("Notes")
#if os(macOS)
                            .foregroundColor(.secondary)
                            .font(.callout)
#endif
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .navigationTitle("reviewTitle")
        .onAppear { load() }
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
        Button("Save", action: save)
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
            WatchlistItemNoteView(id: ItemContent.previewContent.itemNotificationID, showView: .constant(true))
        }
    }
}
