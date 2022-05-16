//
//  CastDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastDetailsView: View {
    let title: String
    let id: Int
    @State private var showBiography: Bool = false
    @State private var isLoading: Bool = true
    @StateObject private var viewModel: CastDetailsViewModel
    @State private var isSharePresented: Bool = false
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: CastDetailsViewModel())
        self.title = title
        self.id = id
    }
    var body: some View {
        ScrollView {
            VStack {
                //MARK: Person image
                ProfileImageView(url: viewModel.person?.itemImage)
                
                //MARK: Biography box
                OverviewBoxView(overview: viewModel.person?.biography, type: .person)
                    .onTapGesture {
                        showBiography.toggle()
                    }
                    .padding()
                    .sheet(isPresented: $showBiography) {
                        NavigationView {
                            ScrollView {
                                Text(viewModel.person?.biography ?? "No information available.")
                                    .padding()
                                    .textSelection(.enabled)
                            }
                            .navigationTitle(title)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showBiography.toggle()
                                    }
                                }
                            }
                        }
                    }
                
                if let adult = viewModel.person?.adult {
                    if !adult {
                        if let filmography = viewModel.person?.combinedCredits {
                            if let cast = filmography.cast,
                               let crew = filmography.crew {
                                let items: [Filmography] = cast + crew
                                FilmographyListView(items: items.sorted(by: { $0.itemPopularity > $1.itemPopularity }))
                            }
                        }
                    }
                }
                
                AttributionView().padding([.top, .bottom])
                    .unredacted()
            }
            .sheet(isPresented: $isSharePresented,
                   content: { ActivityViewController(itemsToShare: [viewModel.person!.itemURL]) })
            .redacted(reason: isLoading ? .placeholder : [])
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        HapticManager.shared.mediumHaptic()
                        isSharePresented.toggle()
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                    .foregroundColor(.accentColor)
                }
            }
        }
        .task { load() }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id)
            if viewModel.isLoaded {
                isLoading = false
            }
        }
    }
}

struct CastDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        CastDetailsView(title: Credits.previewCast.name,
                        id: Credits.previewCast.id)
    }
}

private struct DrawingConstants {
    static let biographyPadding: CGFloat = 4
    static let biographyLineLimits: Int = 4
}
