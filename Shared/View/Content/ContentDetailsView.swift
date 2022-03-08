//
//  ContentDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct ContentDetailsView: View {
    var title: String
    var id: Int
    var type: MediaType
    
    @StateObject private var viewModel = ContentDetailsViewModel()
    @State private var isAboutPresented: Bool = false
    @State private var isSharePresented: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationEnabled: Bool = false
    //@State private var inWatchlist: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                if let content = viewModel.content {
                    HeroImageView(title: content.itemTitle, url: content.cardImage)
                    if !content.itemInfo.isEmpty {
                        Text(content.itemInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred(intensity: 1.0)
                        if !viewModel.inWatchlist {
                            viewModel.add()
                        } else {
                            viewModel.remove()
                        }
                    } label: {
                        Label(!viewModel.inWatchlist ? "Add to watchlist" : "Remove from watchlist", systemImage: !viewModel.inWatchlist ? "plus.square" : "minus.square")
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.inWatchlist ? .red : .blue)
                    .controlSize(.large)
                    GroupBox {
                        Text(content.itemAbout)
                            .padding([.top], 2)
                            .textSelection(.enabled)
                            .lineLimit(4)
                    } label: {
                        Label("About", systemImage: "film")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .onTapGesture {
                        isAboutPresented.toggle()
                    }
                    .sheet(isPresented: $isAboutPresented) {
                        NavigationView {
                            ScrollView {
                                Text(content.itemAbout).padding()
                            }
                            .navigationTitle(content.itemTitle)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        isAboutPresented.toggle()
                                    }
                                }
                            }
                        }
                    }
                    if content.credits != nil {
                        PersonListView(credits: content.credits!)
                    }
                    InformationView(item: content)
                    if content.recommendations != nil {
                        ContentListView(style: StyleType.poster,
                                        type: content.media,
                                        title: "Recommendations",
                                        items: content.recommendations!.results)
                    }
                    AttributionView().padding([.top, .bottom])
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button {
                            isNotificationEnabled.toggle()
                        } label: {
                            withAnimation {
                                Image(systemName: isNotificationEnabled ? "bell.fill" : "bell")
                            }
                        }
                        .opacity(isNotificationAvailable ? 1 : 0)
                        Button {
                            isSharePresented.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $isSharePresented, content: { ActivityViewController(itemsToShare: [title]) })
        }
        .task {
            load()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, type: self.type)
        }
    }
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ContentDetailsView(title: Content.previewContent.itemTitle,
                           id: Content.previewContent.id,
                           type: MediaType.movie)
    }
}
