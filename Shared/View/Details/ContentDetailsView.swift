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
    @StateObject private var viewModel: ContentDetailsViewModel
    @State private var isAboutPresented: Bool = false
    @State private var isSharePresented: Bool = false
    @State private var showSafari: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationScheduled: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var isLoading: Bool = true
    @State private var hiddenMenu: Bool = false
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPad: Bool = UIDevice.isIPad
    @State private var animateFavorite: Bool = false
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ContentDetailsViewModel())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    HeroImage(url: viewModel.content?.cardImageLarge,
                              title: title,
                              blurImage: (viewModel.content?.adult ?? false))
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial)
                        Image(systemName: isFavorite ? "heart.fill" : "heart.slash.fill")
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                    }
                    .opacity(animateFavorite ? 1 : 0)
                }
                .frame(width: isPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                       height: isPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
                .cornerRadius(isPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius)
                .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                        radius: DrawingConstants.shadowRadius)
                .padding([.top, .bottom])
                .onTapGesture(count: 2) {
                    withAnimation {
                        animateFavorite.toggle()
                    }
                    if !isInWatchlist {
                        viewModel.update(markAsWatched: nil, markAsFavorite: nil)
                        withAnimation {
                            isInWatchlist.toggle()
                            isNotificationScheduled.toggle()
                        }
                    }
                    updateFavorite()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            animateFavorite = false
                        }
                    }
                }
                
                GlanceInfo(info: viewModel.content?.itemInfo)
                
                Button(action: {
                    HapticManager.shared.mediumHaptic()
                    viewModel.update(markAsWatched: nil, markAsFavorite: nil)
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
                
                OverviewBoxView(overview: viewModel.content?.itemAbout, type: .movie)
                    .padding()
                    .onTapGesture {
                        withAnimation {
                            isAboutPresented.toggle()
                        }
                    }
                    .sheet(isPresented: $isAboutPresented) {
                        NavigationView {
                            ScrollView {
                                Text(viewModel.content!.itemAbout)
                                    .padding()
                                    .textSelection(.enabled)
                            }
                            .navigationTitle(title)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button(action: { isAboutPresented.toggle() },
                                           label:{ Text("Done") })
                                }
                            }
                        }
                    }
                
                if let trailer = viewModel.content?.itemTrailer {
                    TrailerSectionView(url: viewModel.content?.cardImageMedium,
                                       title: "Trailer",
                                       isPresented: $showSafari)
                    .sheet(isPresented: $showSafari) {
                        SFSafariViewWrapper(url: trailer)
                    }
                }
                
                if let seasons = viewModel.content?.seasonsNumber {
                    if seasons > 0 {
                        HorizontalSeasonView(numberOfSeasons: Array(1...seasons), tvId: id)
                            .padding(0)
                    }
                }
                
                if let cast = viewModel.content?.credits {
                    CastListView(credits: cast)
                }
                
                InformationSectionView(item: viewModel.content)
                    .padding()
                
                if let filmography = viewModel.content?.recommendations {
                    ContentListView(type: type,
                                    title: "Recommendations",
                                    subtitle: "You may like",
                                    image: "list.and.film",
                                    items: filmography.results)
                }
                
                AttributionView().padding([.top, .bottom])
            }
            .sheet(isPresented: $isSharePresented,
                   content: { ActivityViewController(itemsToShare: [viewModel.content!.itemURL]) })
            .redacted(reason: isLoading ? .placeholder : [])
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
                            HapticManager.shared.mediumHaptic()
                            isSharePresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        .disabled(isLoading ? true : false)
                        if hiddenMenu {
                            Menu(content: {
                                Button(action: {
                                    updateWatched()
                                }, label: {
                                    Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                                          systemImage: isWatched ? "minus.circle" : "checkmark.circle")
                                })
                                .disabled(isInWatchlist ? false : true)
                                Button(action: {
                                    updateFavorite()
                                }, label: {
                                    Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                                          systemImage: isFavorite ? "heart.circle.fill" : "heart.circle")
                                })
                                .disabled(isInWatchlist ? false : true)
                            }, label: {
                                Label("More", systemImage: "ellipsis")
                            })
                            .disabled(isLoading ? true : false)
                        }
                    }
                }
            }
        }
        .task { load() }
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
    
    private func updateFavorite() {
        HapticManager.shared.softHaptic()
        isFavorite.toggle()
        viewModel.update(markAsWatched: nil, markAsFavorite: isFavorite)
    }
    
    private func updateWatched() {
        HapticManager.shared.softHaptic()
        isWatched.toggle()
        viewModel.update(markAsWatched: isWatched, markAsFavorite: nil)
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
                        isWatched = viewModel.context.isMarkedAsWatched(id: self.id)
                        isFavorite = viewModel.context.isMarkedAsFavorite(id: self.id)
                    }
                }
                withAnimation {
                    isNotificationAvailable = viewModel.content?.itemCanNotify ?? false
                    if viewModel.content?.itemStatus == .released {
                        hiddenMenu = true
                    }
                    isLoading = false
                }
            }
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

private struct GlanceInfo: View {
    let info: String?
    var body: some View {
        if let info = info {
            Text(info)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

private struct DrawingConstants {
    static let shadowOpacity: Double = 0.2
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
    static let padImageWidth: CGFloat = 500
    static let padImageHeight: CGFloat = 300
    static let padImageRadius: CGFloat = 12
}
