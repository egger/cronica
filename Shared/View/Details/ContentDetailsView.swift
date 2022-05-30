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
    @StateObject private var store: SettingsStore
    @State private var isSharePresented: Bool = false
    @State private var showSafari: Bool = false
    @State private var isNotificationAvailable: Bool = false
    @State private var isNotificationScheduled: Bool = false
    @State private var isInWatchlist: Bool = false
    @State private var isLoading: Bool = true
    @State private var markAsMenuVisibility: Bool = false
    @State private var isWatched: Bool = false
    @State private var isFavorite: Bool = false
    @State private var isPad: Bool = UIDevice.isIPad
    @State private var animateGesture: Bool = false
    @State private var showConfirmation: Bool = false
    @State private var shareItems: [Any] = []
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ContentDetailsViewModel())
        _store = StateObject(wrappedValue: SettingsStore())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ZStack {
                        HeroImage(url: viewModel.content?.cardImageLarge,
                                  title: title,
                                  blurImage: (viewModel.content?.adult ?? false))
                        ZStack {
                            Rectangle().fill(.ultraThinMaterial)
                            if store.gesture == .favorite {
                                Image(systemName: isFavorite ? "heart.fill" : "heart.slash.fill")
                                    .symbolRenderingMode(.multicolor)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120, alignment: .center)
                            } else {
                                Image(systemName: isWatched ? "checkmark.circle" : "minus.circle.fill")
                                    .symbolRenderingMode(.monochrome)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120, alignment: .center)
                            }
                            
                        }
                        .opacity(animateGesture ? 1 : 0)
                    }
                    .frame(width: isPad ? DrawingConstants.padImageWidth : DrawingConstants.imageWidth,
                           height: isPad ? DrawingConstants.padImageHeight : DrawingConstants.imageHeight)
                    .cornerRadius(isPad ? DrawingConstants.padImageRadius : DrawingConstants.imageRadius)
                    .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                            radius: DrawingConstants.shadowRadius)
                    .padding([.top, .bottom])
                    .onTapGesture(count: 2) {
                        withAnimation {
                            animateGesture.toggle()
                        }
                        if !isInWatchlist {
                            viewModel.update(markAsWatched: nil, markAsFavorite: nil)
                            withAnimation {
                                isInWatchlist.toggle()
                                isNotificationScheduled.toggle()
                            }
                        }
                        if store.gesture == .favorite {
                            updateFavorite()
                        } else {
                            updateWatched()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation {
                                animateGesture = false
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibility(hidden: true)
                    
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
                    
                    OverviewBoxView(overview: viewModel.content?.overview, title: title, type: .movie)
                        .padding()
                    
                    if let trailer = viewModel.content?.itemTrailer {
                        TrailerView(url: viewModel.content?.cardImageMedium,
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
                        CastListView(credits: cast.cast + cast.crew)
                    }
                    
                    InformationSectionView(item: viewModel.content)
                        .padding()
                    
                    if let filmography = viewModel.content?.recommendations {
                        ContentListView(type: type,
                                        title: "Recommendations",
                                        subtitle: "You may like",
                                        image: "list.and.film",
                                        items: filmography.results,
                                        showConfirmation: $showConfirmation)
                    }
                    
                    AttributionView().padding([.top, .bottom])
                }
            }
            .task { load() }
            .sheet(isPresented: $isSharePresented,
                   content: { ActivityViewController(itemsToShare: $shareItems) })
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
                            .accessibilityHidden(true)
                        Button(action: {
                            HapticManager.shared.mediumHaptic()
                            shareItems = [URL(string: "https://www.themoviedb.org/\(type.rawValue)/\(id)")!]
                            withAnimation {
                                isSharePresented.toggle()
                            }
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                        .accessibilityLabel("Share")
                        .disabled(isLoading ? true : false)
                        if markAsMenuVisibility {
                            Menu(content: {
                                Button(action: {
                                    updateWatched()
                                }, label: {
                                    Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                                          systemImage: isWatched ? "minus.circle" : "checkmark.circle")
                                })
                                .disabled(isInWatchlist ? false : true)
                                .keyboardShortcut("m", modifiers: [.command, .shift])
                                Button(action: {
                                    updateFavorite()
                                }, label: {
                                    Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                                          systemImage: isFavorite ? "heart.circle.fill" : "heart.circle")
                                })
                                .disabled(isInWatchlist ? false : true)
                                .keyboardShortcut("f", modifiers: [.command, .shift])
                            }, label: {
                                Label("More", systemImage: "ellipsis")
                            })
                            .disabled(isLoading ? true : false)
                        }
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Label("Added to watchlist", systemImage: "checkmark.circle")
                        .padding()
                }
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding()
                .shadow(radius: 6)
                .opacity(showConfirmation ? 1 : 0)
                .scaleEffect(showConfirmation ? 1.1 : 1)
                .animation(.linear, value: showConfirmation)
            }
        }
    }
    
    @ViewBuilder
    private var overlayView: some View {
        switch viewModel.phase {
        case .failure(let error):
            ZStack {
                RetryView(text: error.localizedDescription, retryAction: {
                    Task {
                        await viewModel.load(id: self.id, type: self.type)
                    }
                })
            }
            .padding()
            .background(.regularMaterial)
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
                        markAsMenuVisibility = true
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
