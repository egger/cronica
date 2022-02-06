//
//  CastView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastView: View {
    let title: String
    let id: Int
    @StateObject private var viewModel = CastViewModel()
    var body: some View {
        VStack {
            if let cast = viewModel.cast {
                CastViewBody(cast: cast)
            }
        }
        .navigationTitle(title)
        .task {
            load()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.loadCast(id: self.id)
        }
    }
}

struct CastView_Previews: PreviewProvider {
    static var previews: some View {
        CastViewBody(cast: Credits.previewCast)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
    static let biographyPadding: CGFloat = 4
    static let imageRadius: CGFloat = 12
}

struct CastViewBody: View {
    let cast: Cast
    @State private var showingSheet: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                Button {
                    self.showingSheet = true
                } label: {
                    AsyncImage(url: cast.image) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                            .clipShape(Circle())
                            .padding([.top, .bottom])
                    } placeholder: {
                        ProgressView()
                    }
                }
                .fullScreenCover(isPresented: $showingSheet) {
                    NavigationView {
                        AsyncImage(url: cast.image) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .padding()
                        } placeholder: {
                            ProgressView()
                        }
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button {
                                    self.showingSheet = false
                                } label: {
                                    Text("Done")
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
                GroupBox {
                    Text(cast.biography ?? "")
                        .padding([.top, .bottom], DrawingConstants.biographyPadding)
                } label: {
                    Label("biography", systemImage: "book")
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
}
