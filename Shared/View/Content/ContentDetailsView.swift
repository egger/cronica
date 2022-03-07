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
    @State private var showingAbout: Bool = false
    @State private var inWatchlist: Bool = false
    @State private var reviewScreen: Bool = false
    @State private var reviewText: String = ""
    @State private var reviewBody: String = ""
    @State private var showNotificationButton: Bool = false
    @State private var showShareSheet: Bool = false
    @StateObject private var viewModel = ContentDetailsViewModel()
    var body: some View {
        ScrollView {
            VStack {
                if let item = viewModel.content {
                    DetailsImageView(url: item.cardImage, title: item.itemTitle)
                        .sheet(isPresented: $showShareSheet, content: { ActivityViewController(itemsToShare: [item.itemUrl, title]) })
                    if !item.itemInfo.isEmpty {
                        Text(item.itemInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    WatchlistButtonView(content: item, notify: false, type: type.watchlistInt)
                        .onAppear {
                            print(item.isReleased)
                        }
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
                    if item.credits != nil {
                        PersonListView(credits: item.credits!)
                    }
                    InformationView(item: item)
                    if item.recommendations != nil {
                        ContentListView(style: StyleType.poster,
                                        type: type,
                                        title: "Recommendations",
                                        items: item.recommendations!.results)
                    }
                    AttributionView().padding([.top, .bottom])
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "bell")
                        }
                        .opacity(showNotificationButton ? 1 : 0)
                        Button {
                            showShareSheet.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
            .task {
                load()
            }
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

struct ActivityViewController: UIViewControllerRepresentable {
    var itemsToShare: [Any]
    var servicesToShareItem: [UIActivity]? = nil
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: servicesToShareItem)
        return controller
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
