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
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ContentDetailsViewModel())
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ScrollView {
            VStack {
                HeroImage(url: viewModel.content?.cardImageLarge,
                          title: title,
                          blurImage: (viewModel.content?.adult ?? false))
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .cornerRadius(DrawingConstants.imageRadius)
                    .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                            radius: DrawingConstants.shadowRadius)
                    .padding([.top, .bottom])
                
                GlanceInfo(info: viewModel.content?.itemInfo)
                
                Button(action: {
                    HapticManager.shared.buttonHaptic()
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
                        SeasonListView(title: "Seasons",
                                       id: self.id,
                                       items: viewModel.content!.seasons!)
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
                            HapticManager.shared.buttonHaptic()
                            isSharePresented.toggle()
                        }, label: {
                            Image(systemName: "square.and.arrow.up")
                        })
                        .foregroundColor(.accentColor)
                        .disabled(isLoading ? true : false)
                        if hiddenMenu {
                            Menu(content: {
                                Button(action: {
                                    viewModel.update(markAsWatched: true, markAsFavorite: nil)
                                }, label: {
                                    Label("Mark as Watched", systemImage: "checkmark.circle.fill")
                                })
                                .disabled(isInWatchlist ? false : true)
                                Button(action: {
                                    viewModel.update(markAsWatched: nil, markAsFavorite: true)
                                }, label: {
                                    Label("Mark as Favorite", systemImage: "star.circle.fill")
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
}
