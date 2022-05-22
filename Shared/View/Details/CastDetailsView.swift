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
    @State private var showConfirmation: Bool = false
    @State private var shareItems: [Any] = []
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: CastDetailsViewModel())
        self.title = title
        self.id = id
    }
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    //MARK: Person image
                    ProfileImageView(url: viewModel.person?.personImage, name: viewModel.person?.name ?? "Unnamed Person")
                    
                    //MARK: Biography box
                    OverviewBoxView(overview: viewModel.person?.personBiography, type: .person)
                        .onTapGesture {
                            showBiography.toggle()
                        }
                        .padding()
                        .sheet(isPresented: $showBiography) {
                            NavigationView {
                                ScrollView {
                                    Text(viewModel.person!.personBiography)
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
                            if let cast = viewModel.person?.combinedCredits?.cast {
                                let uniques = Array(Set(cast))
                                FilmographyListView(items: uniques, showConfirmation: $showConfirmation)
                            }
                        }
                    }
                    
                    AttributionView().padding([.top, .bottom])
                        .unredacted()
                }
            }
            .task { load() }
            .sheet(isPresented: $isSharePresented,
                   content: { ActivityViewController(itemsToShare: $shareItems) })
            .redacted(reason: isLoading ? .placeholder : [])
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        HapticManager.shared.mediumHaptic()
                        shareItems = [URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!]
                        withAnimation {
                            isSharePresented.toggle()
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.up")
                    })
                    .foregroundColor(.accentColor)
                }
            }
            VStack {
                Spacer()
                HStack {
                    Label("Added to watchlist", systemImage: "checkmark.circle")
                        .tint(.green)
                        .padding()
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding()
                .shadow(radius: 6)
                .opacity(showConfirmation ? 1 : 0)
                .scaleEffect(showConfirmation ? 1.1 : 1)
                .animation(.linear, value: showConfirmation)
            }
        }
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
