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
    @StateObject private var viewModel: CastDetailsViewModel
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: CastDetailsViewModel())
        self.title = title
        self.id = id
    }
    var body: some View {
        ScrollView {
            if let person = viewModel.person {
                VStack {
                    //MARK: Person image
                    AsyncImage(url: person.itemImage) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil {
                            Rectangle().fill(.secondary)
                        } else {
                            ZStack {
                                Rectangle().fill(.thickMaterial)
                                ProgressView()
                            }
                        }
                    }
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(Circle())
                    .padding([.top, .bottom])
                    //MARK: Biography box
                    if !person.itemBiography.isEmpty {
                        GroupBox {
                            Text(person.itemBiography)
                                .padding([.top, .bottom],
                                         DrawingConstants.biographyPadding)
                                .lineLimit(DrawingConstants.biographyLineLimits)
                        } label: {
                            Label("Biography", systemImage: "book")
                        }
                        .onTapGesture {
                            showBiography.toggle()
                        }
                        .padding()
                        .sheet(isPresented: $showBiography) {
                            NavigationView {
                                ScrollView {
                                    Text(person.itemBiography)
                                        .padding()
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
                    }
                    //MARK: Filmography list
                    if person.combinedCredits != nil {
                        if let filmography = person.combinedCredits!.cast  {
                            VStack {
                                HStack {
                                    Text("Filmography")
                                        .font(.headline)
                                        .padding([.top, .horizontal])
                                    Spacer()
                                }
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack {
                                        ForEach(filmography) { item in
                                            NavigationLink(destination: DetailsView(title: item.itemTitle,
                                                                                           id: item.id,
                                                                                           type: item.itemMedia)) {
                                                PosterView(title: item.itemTitle, url: item.itemImage)
                                                    .padding([.leading, .trailing], 4)
                                            }
                                            .padding(.leading, item.id == filmography.first!.id ? 16 : 0)
                                            .padding(.trailing, item.id == filmography.last!.id ? 16 : 0)
                                            .padding([.top, .bottom])
                                        }
                                    }
                                }
                            }
                        }
                    }
                    //MARK: Attribution
                    AttributionView().padding([.top, .bottom])
                }
            }
        }
        .navigationTitle(title)
        .task { load() }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id)
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
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
    static let biographyPadding: CGFloat = 4
    static let biographyLineLimits: Int = 4
    static let imageRadius: CGFloat = 12
}
