//
//  DetailsView.swift
//  Story
//
//  Created by Alexandre Madeira on 02/03/22.
//

import SwiftUI

struct DetailsView: View {
    var title: String
    var id: Int
    var type: MediaType
    @ObservedObject private var viewModel: DetailsViewModel
    @State private var isAboutPresented: Bool = false
    @State private var isSharePresented: Bool = false
    @State private var showSafari: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationScheduled: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var isLoading: Bool = true
    init(title: String, id: Int, type: MediaType) {
        _viewModel = ObservedObject(wrappedValue: DetailsViewModel())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ScrollView {
            VStack {
                if let content = viewModel.content {
                    VStack {
                        //MARK: Hero Image
                        HeroImage(url: content.cardImageLarge, title: content.itemTitle)
                            .accessibilityLabel("Hero image of \(content.itemTitle).")
                        
                        //MARK: Quick glance info
                        if !content.itemInfo.isEmpty {
                            Text(content.itemInfo)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        //MARK: Watchlist button
                        Button(action: {
                            HapticManager.shared.buttonHaptic()
                            viewModel.update()
                            withAnimation {
                                isInWatchlist.toggle()
                                isNotificationScheduled.toggle()
                            }
                        }, label: {
                            Label(!isInWatchlist ? "Add to watchlist" : "Remove from watchlist",
                                  systemImage: !isInWatchlist ? "plus.square" : "minus.square")
                        })
                        .buttonStyle(.bordered)
                        .tint(!isInWatchlist ? .blue : .red)
                        .controlSize(.large)
                        .disabled(isLoading)
                        .keyboardShortcut("w", modifiers: [.command, .shift])
                        
                        //MARK: About view
                        GroupBox {
                            Text(content.itemAbout)
                                .padding([.top], 2)
                                .lineLimit(4)
                        } label: {
                            Label("About", systemImage: "film")
                                .unredacted()
                        }
                        .padding()
                        .onTapGesture {
                            isAboutPresented.toggle()
                        }
                        .sheet(isPresented: $isAboutPresented) {
                            NavigationView {
                                ScrollView {
                                    Text(content.itemAbout)
                                        .padding()
                                        .textSelection(.enabled)
                                }
                                .navigationTitle(content.itemTitle)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button(action: { isAboutPresented.toggle() },
                                               label:{ Text("Done") })
                                    }
                                }
                            }
                        }
                        
                        //MARK: Trailer view
                        if let trailer = content.itemTrailer {
                            TrailerSectionView(url: content.cardImageMedium, title: "Trailer", isPresented: $showSafari)
                                .sheet(isPresented: $showSafari) {
                                    SFSafariViewWrapper(url: trailer)
                                }
                        }
                        
                        //MARK: Season view
                        if content.seasonsNumber > 0 {
                            SeasonListView(title: "Seasons", id: self.id, items: content.seasons!)
                        }
                        
                        //MARK: Cast view
                        if let cast = content.credits {
                            CastListView(credits: cast)
                        }
                        
                        //MARK: Information view
                        InformationSectionView(item: content)
                        
                        //MARK: Recommendation view
                        if let filmography = content.recommendations {
                            ContentListView(style: StyleType.poster,
                                            type: content.itemContentMedia,
                                            title: "Recommendations",
                                            subtitle: "You may like",
                                            image: "list.and.film",
                                            items: filmography.results)
                        }
                        
                        //MARK: Attribution view
                        AttributionView().padding([.top, .bottom])
                    }
                    .redacted(reason: isLoading ? .placeholder : [])
                    .sheet(isPresented: $isSharePresented,
                           content: { ActivityViewController(itemsToShare: [content.itemURL]) })
                }
            }
            .overlay(overlayView)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Image(systemName: isNotificationScheduled ? "bell.fill" : "bell")
                            .opacity(isNotificationAvailable ? 1 : 0)
                            .foregroundColor(.accentColor)
                        Button(action: {
                            HapticManager.shared.buttonHaptic()
                            isSharePresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        .foregroundColor(.accentColor)
                        .disabled(isLoading ? true : false)
                    }
                }
            }
        }
        .task {
            load()
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .failure(let error):
            RetryView(text: error.localizedDescription, retryAction: {
                Task {
                    await viewModel.load(id: self.id, type: self.type)
                }
            })
        default:
            EmptyView()
        }
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.id, type: self.type)
            if viewModel.content != nil {
                isInWatchlist = viewModel.context.isItemInList(id: self.id)
                if isInWatchlist {
                    withAnimation {
                        isNotificationScheduled = viewModel.context.isNotificationScheduled(id: self.id)
                    }
                }
                withAnimation {
                    isNotificationAvailable = viewModel.itemCanNotify()
                    isLoading = false
                }
            }
        }
    }
    
}

struct ContentDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        DetailsView(title: Content.previewContent.itemTitle,
                    id: Content.previewContent.id,
                    type: MediaType.movie)
    }
}

enum OverviewType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case content, biography, episode
    var image: String {
        switch self {
        case .content: return "film"
        case .biography: return "book"
        case .episode: return "tv"
        }
    }
    var title: String {
        switch self {
        case .content: return "About"
        case .biography: return "Biography"
        case .episode: return "Overview"
        }
    }
}
