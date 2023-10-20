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
    @State private var showReviewImageSheet = false
    let persistence = PersistenceController.shared
    @State private var image = Image(systemName: "photo")
    @Environment(\.displayScale) var displayScale
    @State private var renderedImage = Image(systemName: "photo")
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
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    ShareLink(item: renderedImage,
                              subject: Text("Review of \(item?.itemTitle ?? "")"),
                              message: Text(note),
                              preview: SharePreview("Review of \(item?.itemTitle ?? "")", image: renderedImage))
//                    Button {
//                        showReviewImageSheet.toggle()
//                    } label: {
//                        Label("Share", systemImage: "square.and.arrow.up")
//                    }
                    saveButton
                }
            }
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
        let item = persistence.fetch(for: id)
        guard let item else {
            return
        }
        if note.isEmpty { note = item.userNotes }
        rating = Int(item.userRating)
        self.item = item
        withAnimation { isLoading = false }
        loadImage()
    }
    
    private func loadImage() {
        #if !os(macOS)
        Task {
            let image = await NetworkService.shared.downloadImageData(from: item?.backCompatibleCardImage)
            guard let image else { return }
            guard let uiImage = UIImage(data: image) else { return }
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
                render()
            }
        }
        #endif
    }
    
    @MainActor
    private func render() {
        #if !os(macOS)
        let renderer = ImageRenderer(content: reviewImage)
        renderer.scale = displayScale
        guard let uiImage = renderer.uiImage else { return }
        renderedImage = Image(uiImage: uiImage)
        #endif
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
    
    private var reviewImage: some View {
        ZStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay {
                    VStack {
                        Color.black.opacity(0.5)
                            .mask {
                                LinearGradient(colors:
                                                [Color.black,
                                                 Color.black.opacity(0.924),
                                                 Color.black.opacity(0.707),
                                                 Color.black.opacity(0.383),
                                                 Color.black.opacity(0)],
                                               startPoint: .top,
                                               endPoint: .bottom)
                            }
                            .frame(height: 90)
                        Spacer()
                        if !note.isEmpty  {
                            Color.black.opacity(0.6)
                                .mask {
                                    LinearGradient(colors:
                                                    [Color.black,
                                                     Color.black.opacity(0.924),
                                                     Color.black.opacity(0.707),
                                                     Color.black.opacity(0.383),
                                                     Color.black.opacity(0)],
                                                   startPoint: .bottom,
                                                   endPoint: .top)
                                }
                                .frame(height: 90)
                        }
                    }
                }
                .frame(width: 720, height: 400, alignment: .center)
            VStack(alignment: .leading) {
                HStack {
                    Text(item?.itemTitle ?? "")
                        .lineLimit(2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                    RatingView(rating: $rating)
                }
                .padding(.horizontal)
                .padding(.top)
                Spacer()
                
                Text(note)
                    .foregroundStyle(.white)
                    .font(.caption)
                    .lineLimit(4)
                    .padding([.horizontal, .bottom])
            }
            .frame(width: 720, height: 400, alignment: .center)
        }
        .frame(width: 720, height: 400, alignment: .center)
    }
}

#Preview {
    NavigationStack {
        ReviewView(id: ItemContent.example.itemContentID, showView: .constant(true))
    }
}
