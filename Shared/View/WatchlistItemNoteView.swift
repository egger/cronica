//
//  WatchlistItemNoteView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/04/23.
//

import SwiftUI

struct WatchlistItemNoteView: View {
    let item: WatchlistItem
    @Binding var showView: Bool
    @State private var note = String()
    @State private var rating = 0
    var body: some View {
        Form {
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
        }
        .navigationTitle("reviewTitle")
        .onAppear {
            if note.isEmpty { note = item.userNotes }
            rating = Int(item.userRating)
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
    
    private var doneButton: some View {
        Button("Cancel", action: dismiss)
    }
    
    private var saveButton: some View {
        Button("Save", action: save)
    }
    
    private func save() {
        PersistenceController.shared.updateReview(for: item, rating: rating, notes: note)
        dismiss()
    }
    
    private func dismiss() {
        showView.toggle()
    }
}

struct WatchlistItemNoteView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            WatchlistItemNoteView(item: .example, showView: .constant(true))
        }
    }
}