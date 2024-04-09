//
//  WatchlistItemNoteView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 25/04/23.
//

import SwiftUI
import NukeUI

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
    @StateObject private var settings: SettingsStore = .shared
    var body: some View {
        NavigationStack {
            Form {
                if isLoading {
                    Section {
                        CenterHorizontalView { ProgressView().padding() }
                    }
                } else {
                    if let item {
                        Section { 
                            HStack {
                                LazyImage(url: item.itemPosterImageMedium) { state in
                                    if let image = state.image {
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } else {
                                        ZStack {
                                            Rectangle().fill(.gray.gradient)
                                            Image(systemName: "popcorn.fill")
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                    }
                                }
                                .frame(width: 60, height: 90, alignment: .center)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                .shadow(radius: 2.5, x: 1, y: 1.5)
                                VStack(alignment: .leading) {
                                    Text(item.itemTitle)
                                        .lineLimit(2)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                    Spacer()
                                    Text(item.itemMedia.title)
                                        .lineLimit(1)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(.secondary)
                                        .padding(.leading, 4)
                                        .padding(.bottom, 8)
                                }
                            }
                        }.listRowBackground(Color.clear)
                        
                        Section("Rating") {
                            CenterHorizontalView {
                                RatingView(rating: $rating)
                            }
                        }
#if os(iOS) || os(macOS)
                        Section("Notes") {
                            TextEditor(text: $note)
                                .frame(minHeight: 150, maxHeight: 800)

                        }
#endif
                    } else {
                        ProgressView()
                    }
                }
            }
#if os(iOS)
            .background {
                if let item {
                    TranslucentBackground(image: item.itemPosterImageMedium, useLighterMaterial: true)
                }
            }
            .scrollContentBackground(settings.disableTranslucent ? .visible : .hidden)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .navigationTitle("Review")
            .onAppear(perform: load)
            .onChange(of: rating) { _, newValue in
                guard let item else { return }
                if newValue != Int(item.userRating) {
                    if !canSave { canSave = true }
                    save(dismiss: false)
                }
            }
            .onChange(of: note) { _, newValue in
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
#if !os(tvOS)
            .scrollContentBackground(.hidden)
#endif
            .scrollBounceBehavior(.basedOnSize)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
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
    
    @ViewBuilder
    private var doneButton: some View {
        EmptyView()
        #warning("make RoundedCloseButton available to watchOS")
        //RoundedCloseButton(action: dismiss)
    }
    
    private var saveButton: some View {
        Button("Save") { save() }
            .disabled(!canSave)
            .buttonBorderShape(.capsule)
            .buttonStyle(.borderedProminent)
    }
    
    private func save(dismiss: Bool = true) {
        guard let item else { return }
        persistence.updateReview(for: item, rating: rating, notes: note)
        if dismiss {
            self.dismiss()
        }
    }
    
    private func dismiss() { showView.toggle() }
}

#Preview {
    NavigationStack {
        ReviewView(id: ItemContent.example.itemContentID, showView: .constant(true))
    }
}
