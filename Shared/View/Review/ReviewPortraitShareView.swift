//
//  ReviewPortraitShareView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 28/09/23.
//

import SwiftUI
#if !os(tvOS) && !os(macOS)
struct ReviewPortraitShareView: View {
    let item: WatchlistItem
    @Binding var rating: Int
    let review: String
    @Environment(\.displayScale) var displayScale
    @State private var renderedImage = Image(systemName: "photo")
    @State private var image = Image(systemName: "photo")
    @State private var isLoading = true
    @Binding var showView: Bool
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    if isLoading {
                        ProgressView()
                    } else {
                        previewLandscape
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                            .padding()
                        
                        ShareLink(item: renderedImage,
                                  subject: Text("Review of \(item.itemTitle)"),
                                  message: Text(review),
                                  preview: SharePreview("Review of \(item.itemTitle)", image: renderedImage)) {
                            Label("Share Image", systemImage: "square.and.arrow.up")
                                .frame(width: 200)
                        }
                                  .controlSize(.large)
                                  .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") { showView.toggle() }
            }
            .onAppear {
                Task {
                    let image = await NetworkService.shared.downloadImageData(from: item.backCompatibleCardImage)
                    guard let image else { return }
                    guard let uiImage = UIImage(data: image) else { return }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.image = Image(uiImage: uiImage)
                        render()
                    }
                }
            }
            
        }
    }
    
    @MainActor 
    private func render() {
        let renderer = ImageRenderer(content: previewLandscape)
        renderer.scale = displayScale
        guard let uiImage = renderer.uiImage else { return }
        renderedImage = Image(uiImage: uiImage)
    }
    
    private var previewLandscape: some View {
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
                        if !review.isEmpty  {
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
                .frame(width: 360, height: 200, alignment: .center)
            VStack(alignment: .leading) {
                HStack {
                    Text(item.itemTitle)
                        .lineLimit(2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    Spacer()
                    RatingView(rating: $rating)
                }
                .padding(.horizontal)
                .padding(.top)
                Spacer()
                
                Text(review)
                    .foregroundStyle(.white)
                    .font(.caption)
                    .lineLimit(4)
                    .padding([.horizontal, .bottom])
            }
            .frame(width: 360, height: 200, alignment: .center)
        }
        .frame(width: 360, height: 200, alignment: .center)
    }
}

#Preview {
    ReviewPortraitShareView(item: .example, rating: .constant(4), review: String(), showView: .constant(true))
}
#endif
