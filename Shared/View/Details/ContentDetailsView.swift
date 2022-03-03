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
    @StateObject private var viewModel = ContentDetailsViewModel()
    var body: some View {
        ScrollView {
            VStack {
                if let item = viewModel.content {
                    DetailsImageView(url: item.cardImage, title: item.itemTitle)
                    if item.itemInfo != nil {
                        Text(item.itemInfo!)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    WatchlistButtonView(title: item.itemTitle,
                                        id: item.id,
                                        image: item.cardImage,
                                        status: "",
                                        notify: false,
                                        type: 1)
                    AboutView(overview: item.itemAbout)
                        .onTapGesture {
                            showingAbout.toggle()
                        }
                        .sheet(isPresented: $showingAbout) {
                            NavigationView {
                                ScrollView {
                                    Text(item.itemAbout)
                                        .padding()
                                }
                                .navigationTitle(item.itemTitle)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Done") {
                                            showingAbout.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    Divider()
                        .padding([.horizontal, .top])
                    if item.credits != nil {
                        PersonListView(credits: item.credits!)
                        Divider()
                            .padding([.horizontal, .top])
                    }
                    if type == MediaType.movie {
                        InformationView(item: item)
                        Divider()
                            .padding([.horizontal, .top])
                    }
                    if item.similar != nil {
                        ContentListView(style: StyleType.poster,
                                        type: type,
                                        title: "Similar",
                                        items: item.similar?.results)
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

//struct ContentDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentDetailsView()
//    }
//}
