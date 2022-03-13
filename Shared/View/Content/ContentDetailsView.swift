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
    @ObservedObject private var settings: SettingsStore = SettingsStore()
    @State private var isAboutPresented: Bool = false
    @State private var isSharePresented: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationEnabled: Bool = false
    var body: some View {
        ScrollView {
            VStack {
                if let content = viewModel.content {
                    HeroImageView(title: content.itemTitle, url: content.cardImageLarge)
                    if !content.itemInfo.isEmpty {
                        Text(content.itemInfo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .onAppear {
                                if !content.isReleased { isNotificationAvailable.toggle() }
                                print("Is \(content.itemTitle) released? \(content.isReleased). \(content.itemReleaseDate)")
                            }
                    }
                    //MARK: Watchlist button
                    Button {
#if os(iOS)
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred(intensity: 1.0)
#endif
                        if !viewModel.inWatchlist {
                            if settings.isAutomaticallyNotification {
                                isNotificationEnabled.toggle()
                            }
                            viewModel.add(notify: settings.isAutomaticallyNotification)
                        } else {
                            viewModel.remove()
                        }
                    } label: {
                        withAnimation {
                            Label(!viewModel.inWatchlist ? "Add to watchlist" : "Remove from watchlist", systemImage: !viewModel.inWatchlist ? "plus.square" : "minus.square")
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.inWatchlist ? .red : .blue)
#if os(tvOS)
#else
                    .controlSize(.large)
#endif
                    //MARK: About view
#if os(tvOS)
                    #else
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
#if os(iOS)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        isAboutPresented.toggle()
                                    }
                                }
                            }
#endif
                        }
                    }
#endif
                    if content.seasonsNumber > 0 {
                        SeasonListView(title: "Seasons", id: id, items: content.seasons!)
                    }
                    if content.credits != nil {
                        PersonListView(credits: content.credits!)
                    }
                    InformationView(item: content)
                    if content.recommendations != nil {
                        ContentListView(style: StyleType.poster,
                                        type: content.itemContentMedia,
                                        title: "Recommendations",
                                        items: content.recommendations!.results)
                    }
                    AttributionView().padding([.top, .bottom])
                }
            }
            .navigationTitle(title)
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
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
                        .help("Notify when released.")
                        .opacity(isNotificationAvailable ? 1 : 0)
                        Button {
                            isSharePresented.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
#if os(iOS)
            .sheet(isPresented: $isSharePresented, content: { ActivityViewController(itemsToShare: [title]) })
#endif
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
