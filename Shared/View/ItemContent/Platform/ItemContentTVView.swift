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
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    @State private var hasFocused = false
    @FocusState var isWatchlistInFocus: Bool
    @FocusState var isWatchInFocus: Bool
    @FocusState var isFavoriteInFocus: Bool
    var body: some View {
        VStack {
            ScrollView {
                v2header
                    .padding(.bottom)
                if let seasons = viewModel.content?.itemSeasons {
                    SeasonList(showID: id, showTitle: title, numberOfSeasons: seasons, isInWatchlist: $viewModel.isInWatchlist)
                }
                HorizontalItemContentListView(items: viewModel.recommendations,
                                              title: "Recommendations",
                                              showPopup: $showPopup,
                                              popupType: $popupType,
                                              displayAsCard: true)
                CastListView(credits: viewModel.credits)
                    .padding(.bottom)
                AttributionView()
            }
            .ignoresSafeArea(.all, edges: .horizontal)
        }
        .ignoresSafeArea(.all, edges: .horizontal)
        .onAppear {
            if !hasFocused {
                DispatchQueue.main.async {
                    isWatchlistButtonFocused = true
                    hasFocused = true
                }
            }
        }
    }
    
    private var v2header: some View {
        HStack {
            Spacer()
            
            WebImage(url: viewModel.content?.posterImageLarge)
                .resizable(resizingMode: .stretch)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        VStack {
                            Image(systemName: "popcorn.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                            Text(title)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                                .padding()
                            
                        }
                        .padding()
                    }
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 450, height: 700)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(radius: 5)
                .padding()
                .accessibility(hidden: true)
            
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.title2)
                    .padding(.bottom)
                Button {
                    showOverview.toggle()
                } label: {
                    HStack {
                        Text(viewModel.content?.itemOverview ?? String())
                            .font(.callout)
                            .fontDesign(.rounded)
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
                    
                    VStack {
                        DetailWatchlistButton(showCustomList: .constant(false))
                            .environmentObject(viewModel)
                            .buttonStyle(.borderedProminent)
                            .prefersDefaultFocus(in: tvOSActionNamespace)
                            .focused($isWatchlistButtonFocused)
                        Text(viewModel.isInWatchlist ? "Remove" : "Add")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .opacity(isWatchlistInFocus ? 1 : 0)
                    }
                    .focused($isWatchlistInFocus)
                    
                    VStack {
                        Button {
                            viewModel.update(.watched)
                            viewModel.isWatched ? animate(for: .markedWatched) : animate(for: .removedWatched)
                        } label: {
                            Label(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched",
                                  systemImage: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                            .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderedProminent)
                        Text("Watched")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .opacity(isWatchInFocus ? 1 : 0)
                    }
                    .focused($isWatchInFocus)
                    
                    VStack {
                        Button {
                            viewModel.update(.favorite)
                            viewModel.isFavorite ? animate(for: .markedFavorite) : animate(for: .removedFavorite)
                        } label: {
                            Label(viewModel.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                                  systemImage: viewModel.isFavorite ? "heart.circle.fill" : "heart.circle")
                            .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderedProminent)
                        Text("Favorite")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .opacity(isFavoriteInFocus ? 1 : 0)
                    }
                    .focused($isFavoriteInFocus)
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
    
    private func animate(for action: ActionPopupItems) {
        popupType = action
        withAnimation { showPopup = true }
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
