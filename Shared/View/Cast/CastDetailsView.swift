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
    @State private var isLoading: Bool = true
    @StateObject private var viewModel: CastDetailsViewModel
    @State private var showConfirmation: Bool = false
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
                        .shadow(radius: 6)
                    
                    //MARK: Biography box
                    OverviewBoxView(overview: viewModel.person?.biography, title: title, type: .person)
                        .padding()
                    
                    if let adult = viewModel.person?.isAdult {
                        if !adult {
                            if let cast = viewModel.person?.combinedCredits?.cast {
                                ItemContentListView(items: cast.sorted(by: { $0.itemPopularity > $1.itemPopularity }),
                                                    title: "Filmography",
                                                    subtitle: "Know for",
                                                    image: "list.and.film",
                                                    addedItemConfirmation: $showConfirmation)
                            }
                        }
                    }
                    
                    AttributionView().padding([.top, .bottom])
                        .unredacted()
                }
            }
            .task { load() }
            .redacted(reason: isLoading ? .placeholder : [])
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    ShareLink(item: URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!) 
                }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
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
