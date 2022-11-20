//
//  PersonDetailsView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonDetailsView: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 440))
    ]
    let name: String
    @State private var isLoading = true
    @StateObject private var viewModel: PersonDetailsViewModel
    init(title: String, id: Int) {
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.name = title
    }
    var body: some View {
        ScrollView {
            ZStack {
                if !viewModel.isLoaded { ProgressView("Loading").unredacted() }
                VStack {
                    HStack {
                        WebImage(url: viewModel.person?.personImage)
                            .resizable()
                            .placeholder {
                                VStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.white)
                                        .opacity(0.8)
                                        .font(.title)
                                }
                                .frame(width: DrawingConstants.imageWidth,
                                       height: DrawingConstants.imageHeight)
                                .clipShape(Circle())
                                .background(.gray.gradient)
                            }
                            .transition(.opacity)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: DrawingConstants.imageWidth,
                                   height: DrawingConstants.imageHeight)
                            .clipShape(Circle())
                        Text(name)
                            .font(.title2)
                    }
                    .padding()
                    if !viewModel.credits.isEmpty {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.credits) { item in
                                ItemContentCardView(item: item)
                            }
                        }
                    } else {
                        CenterHorizontalView {
                            Text("No Filmography.")
                        }
                    }
                }
            }
            .task {
                await viewModel.load()
            }
            .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
        }
        .background {
            TranslucentBackground(image: viewModel.person?.personImage)
        }
    }
}

struct PersonDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailsView(title: Person.previewCast.name, id: Person.previewCast.id)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 200
    static let imageHeight: CGFloat = 200
}
