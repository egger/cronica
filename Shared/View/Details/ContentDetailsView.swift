//
//  ContentDetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct ContentDetailsView: View {
    var title: String
    var id: Content.ID
    var type: MediaType
    @State private var showingAbout: Bool = false
    @State private var inWatchlist: Bool = false
    @State private var reviewScreen: Bool = false
    @State private var reviewText: String = ""
    @State private var reviewBody: String = ""
    @StateObject private var viewModel = ContentDetailsViewModel()
    var body: some View {
        ScrollView {
            VStack {
                if let item = viewModel.content {
                    DetailsImageView(url: item.cardImage, title: item.itemTitle)
                    
                    WatchlistButtonView(content: item, notify: false, type: type.watchlistInt)
                    
                    GroupBox {
                        Text(item.itemAbout)
                            .padding([.top], 2)
                            .textSelection(.enabled)
                            .lineLimit(4)
                    } label: {
                        Label("About", systemImage: "film")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .onTapGesture {
                        showingAbout.toggle()
                    }
                    .sheet(isPresented: $showingAbout) {
                        NavigationView {
                            ScrollView {
                                Text(item.itemAbout).padding()
                            }
                            .navigationTitle(item.itemTitle)
#if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        showingAbout.toggle()
                                    }
                                }
                            }
#endif
                        }
                    }
                    
                    if item.credits != nil {
                        Divider().padding(.horizontal)
                        PersonListView(credits: item.credits!)
                    }
                    
                    switch type {
                    case .movie:
                        Divider().padding(.horizontal)
                        InformationView(item: item)
                    case .person:
                        EmptyView()
                    case .tvShow:
                        EmptyView()
                    }
                    
                    if item.recommendations != nil {
                        Divider().padding(.horizontal)
                        ContentListView(style: StyleType.poster,
                                        type: type,
                                        title: "Recommendations",
                                        items: item.recommendations!.results)
                    }
                    
                    AttributionView().padding(.bottom)
                    
                }
            }
        }
        .sheet(isPresented: $reviewScreen) {
            NavigationView {
                Form {
                    Section(header: Text("Review Title")) {
                        TextField("", text: $reviewText)
                    }
                    Section(header: Text("Review")) {
                        TextField("", text: $reviewBody)
                    }
                }
                .navigationTitle("Review")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel", role: .destructive) {
                            
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Publish") {
                            
                        }
                    }
                }
            }
            
        }
        .navigationTitle(title)
        .toolbar {
            ToolbarItem {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
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
