//
//  PersonView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct PersonView: View {
    let title: String
    let id: Int
    @State private var showingSheet: Bool = false
    @StateObject private var viewModel = PersonViewModel()
    var body: some View {
        VStack {
            if let cast = viewModel.cast {
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
#if os(iOS)
                        .sheet(isPresented: $showingSheet) {
                            NavigationView {
                                VStack {
                                    AsyncImage(url: cast.image) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .padding()
                                            .padding(.bottom)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                .navigationTitle(title)
                                .navigationBarTitleDisplayMode(.inline)
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
#endif
                        if cast.biography != nil {
                            GroupBox {
                                Text(cast.biography ?? "")
                                    .padding([.top, .bottom], DrawingConstants.biographyPadding)
                                    .lineLimit(6)
                            } label: {
                                Label("Biography", systemImage: "book")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                    }
                }
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
            await self.viewModel.load(id: self.id)
        }
    }
}

//struct CastView_Previews: PreviewProvider {
//    static var previews: some View {
//        CastViewBody(cast: Credits.previewCast)
//    }
//}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 150
    static let imageHeight: CGFloat = 150
    static let biographyPadding: CGFloat = 4
    static let imageRadius: CGFloat = 12
}
