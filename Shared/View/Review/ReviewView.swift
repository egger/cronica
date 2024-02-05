//
//  WatchlistItemNoteView.swift
//  Cronica (iOS)
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
    @State private var showReviewImageSheet = false
    let persistence = PersistenceController.shared
    var body: some View {
        NavigationStack {
            Form {
                if isLoading {
                    Section {
                        CenterHorizontalView { ProgressView().padding() }
                    }
                } else {
                    if let item {
                        Section("About") { Text("Review of \(item.itemTitle)") }
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
            .navigationTitle("Review")
            .onAppear(perform: load)
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
                ToolbarItem(placement: .topBarLeading) { doneButton }
                ToolbarItem(placement: .topBarTrailing) { saveButton }
#else
                ToolbarItem(placement: .confirmationAction) { saveButton }
                ToolbarItem(placement: .cancellationAction) { doneButton }
#endif
            }
#if os(macOS)
            .formStyle(.grouped)
#endif
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .presentationDetents([.large, .medium])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThickMaterial)
#if os(macOS)
        .frame(width: 400, height: 400, alignment: .center)
#elseif os(iOS)
        .appTheme()
        .appTint()
#endif
    }
    
    private func load() {
        let item = persistence.fetch(for: id)
        guard let item else {
            return
        }
        if note.isEmpty { note = item.userNotes }
        rating = Int(item.userRating)
        self.item = item
        isLoading = false
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

#Preview {
    NavigationStack {
        ReviewView(id: ItemContent.example.itemContentID, showView: .constant(true))
    }
}
