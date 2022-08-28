//
//  ItemContentView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentView: View {
    let title: String
    let url: URL
    @StateObject private var viewModel: ItemContentViewModel
    init(id: Int, title: String, type: MediaType) {
        self.title = title
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.url = URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!
    }
    var body: some View {
        VStack {
            ScrollView {
                HeroImage(url: viewModel.content?.cardImageMedium, title: title)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius,
                                                style: .continuous))
                    .padding()
                
                WatchlistButtonView()
                    .environmentObject(viewModel)
                    .padding()
                
                watchButton
                    .padding([.horizontal, .bottom])
                
                ShareLink(item: url)
                    .padding([.horizontal, .bottom])
                
                AboutSectionView(about: viewModel.content?.itemOverview)
                
                CompanionTextView()
                
                AttributionView()
            }
        }
        .task {
            await viewModel.load()
        }
        .navigationTitle(title)
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
    }
    private var watchButton: some View {
        Button(action: {
            viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
        }, label: {
            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle.fill")
        })
        .buttonStyle(.bordered)
        .tint(viewModel.isWatched ? .yellow : .green)
        .controlSize(.large)
        .disabled(viewModel.isLoading)
    }
}

struct ItemContentView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentView(id: ItemContent.previewContent.id,
                        title: ItemContent.previewContent.itemTitle,
                        type: ItemContent.previewContent.itemContentMedia)
    }
}

private struct DrawingConstants {
    static let imageRadius: CGFloat = 12
}

private struct AboutSectionView: View {
    let about: String?
    var body: some View {
        if let about {
            Divider().padding(.horizontal)
            Section {
                Text(about)
            } header: {
                HStack {
                    Label("About", systemImage: "film")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            Divider().padding(.horizontal)
        }
    }
}
