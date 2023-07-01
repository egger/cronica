//
//  ItemContentTVView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/05/23.
//

import SwiftUI
import SDWebImageSwiftUI
#if os(tvOS)
struct ItemContentTVView: View {
    let title: String
    let type: MediaType
    let id: Int
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var showOverview = false
    @State private var showReleaseDateInfo = false
    @State private var showCustomList = false
    @Namespace var tvOSActionNamespace
    @FocusState var isWatchlistButtonFocused: Bool
    var body: some View {
        VStack {
            ScrollView {
                v2header
                    .padding(.bottom)
                if let seasons = viewModel.content?.itemSeasons {
                    SeasonList(showID: id, numberOfSeasons: seasons)
                        .ignoresSafeArea(.all, edges: .horizontal)
                }
                HorizontalItemContentListView(items: viewModel.recommendations,
                                    title: "Recommendations",
                                    subtitle: String(),
                                    addedItemConfirmation: .constant(false),
                                    displayAsCard: false)
                .ignoresSafeArea()
                CastListView(credits: viewModel.credits)
                    .padding(.bottom)
                AttributionView()
            }
            .ignoresSafeArea(.all, edges: .horizontal)
        }
        .task { await viewModel.load() }
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .ignoresSafeArea(.all, edges: .horizontal)
        .background {
            TranslucentBackground(image: viewModel.content?.cardImageLarge)
        }
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .onAppear {
            DispatchQueue.main.async {
                isWatchlistButtonFocused = true
            }
        }
    }
    
    private var v2header: some View {
        HStack {
            Spacer()
            
            WebImage(url: viewModel.content?.posterImageMedium)
                .resizable(resizingMode: .stretch)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        VStack {
                            Text(title)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                                .padding()
                            Image(systemName: type == .tvShow ? "tv" : "film")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                            
                        }
                        .padding()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 500, height: 800)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(radius: 16)
                .padding()
                .accessibility(hidden: true)
            
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.black)
                    .font(.title2)
                    .padding(.bottom)
                Button {
                    showOverview.toggle()
                } label: {
                    HStack {
                        Text(viewModel.content?.itemOverview ?? "")
                            .font(.callout)
                            .lineLimit(10)
                            .onTapGesture {
                                showOverview.toggle()
                            }
                        Spacer()
                    }
                    .frame(maxWidth: 700)
                    .padding(.bottom)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showOverview) {
                    NavigationStack {
                        ScrollView {
                            Text(viewModel.content?.itemOverview ?? "")
                                .padding()
                        }
                        .navigationTitle(title)
                    }
                }
                
                // Actions
                HStack {
                    
                    DetailWatchlistButton()
                        .environmentObject(viewModel)
                        .buttonStyle(.borderedProminent)
                        .prefersDefaultFocus(in: tvOSActionNamespace)
                        .focused($isWatchlistButtonFocused)
                    Button {
                        viewModel.update(.watched)
                    } label: {
                        Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                              systemImage: viewModel.isWatched ? "rectangle.badge.minus" : "rectangle.badge.checkmark.fill")
                        .labelStyle(.iconOnly)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if viewModel.isInWatchlist {
                        if let id = viewModel.content?.itemContentID {
                            Button {
                                showCustomList.toggle()
                            } label: {
                                Label("addToList", systemImage: "rectangle.on.rectangle.angled")
                                    .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.borderedProminent)
                            .sheet(isPresented: $showCustomList) {
                                NavigationStack {
                                    ItemContentCustomListSelector(contentID: id,
                                                                  showView: $showCustomList,
                                                                  title: title)
                                }
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
#if os(macOS)
                                .frame(width: 500, height: 600, alignment: .center)
#else
                                .appTheme()
                                .appTint()
#endif
                            }
#if os(macOS) || os(iOS)
                            .keyboardShortcut("k", modifiers: [.option])
#endif
                            
                            Button {
                                
                            } label: {
                                Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                                      systemImage: viewModel.isFavorite ? "heart.slash.circle.fill" : "heart.circle")
                                .labelStyle(.iconOnly)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    Spacer()
                }
            }
            .frame(width: 700)
            
            QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                .frame(width: 400)
                .padding(.trailing)
            
            Spacer()
        }
    }
}

struct ItemContentTVView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentTVView(title: "Preview", type: .movie, id: ItemContent.example.id)
    }
}

struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
            configuration.title
        }
    }
}
#endif
