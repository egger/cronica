//
//  ItemContentPhoneView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

#if os(iOS)
struct ItemContentPhoneView: View {
    let title: String
    let type: MediaType
    let id: Int
    @Binding var showPopup: Bool
    @Binding var showWatchedPopup: Bool
    @EnvironmentObject var viewModel: ItemContentViewModel
    @StateObject private var store = SettingsStore.shared
    @State private var animateGesture = false
    @State private var animationImage = ""
    @State private var showReleaseDateInfo = false
    @Binding var showCustomList: Bool
    @State private var navigationTitle = String()
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        VStack {
            cover
            
            actions
            
            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: title).padding()
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, showTitle: title, numberOfSeasons: seasons)
                    .padding([.top, .horizontal], .zero)
                    .padding(.bottom)
            }
            
            TrailerListView(trailers: viewModel.content?.itemTrailers)
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            HorizontalItemContentListView(items: viewModel.recommendations,
                                          title: "Recommendations",
                                          showPopup: $showPopup,
                                          popupType: $popupType,
                                          displayAsCard: true)
            
            infoBox(item: viewModel.content, type: type).padding()
                .sheet(isPresented: $showReleaseDateInfo) {
                    DetailedReleaseDateView(item: viewModel.content?.releaseDates?.results,
                                            dismiss: $showReleaseDateInfo)
                }
            
            AttributionView().padding([.top, .bottom])
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if !navigationTitle.isEmpty {
                navigationTitle = String()
            }
        }
    }
    
    private var actions: some View {
        HStack {
            if viewModel.isInWatchlist {
                Button {
                    viewModel.update(.watched)
                    popupType = viewModel.isWatched ? .markedWatched : .removedWatched
                    withAnimation { showPopup = true }
                } label: {
                    VStack {
                        Image(systemName: viewModel.isWatched ? "rectangle.badge.checkmark.fill" : "rectangle.badge.checkmark")
                        Text("Watched")
                            .padding(.top, 2)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 4)
                    .frame(width: 60)
                }
                .keyboardShortcut("w", modifiers: [.option])
                .controlSize(.small)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .tint(.primary)
                .padding(.horizontal)
            }
            DetailWatchlistButton(showCustomList: $showCustomList)
                .keyboardShortcut("l", modifiers: [.option])
                .environmentObject(viewModel)
            if viewModel.isInWatchlist {
                Button {
                    showCustomList.toggle()
                } label: {
                    VStack {
                        Image(systemName: viewModel.isItemAddedToAnyList ? "rectangle.on.rectangle.angled.fill" : "rectangle.on.rectangle.angled")
                        Text("Lists")
                            .padding(.top, 2)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.vertical, 4)
                    .frame(width: 60)
                }
                .controlSize(.small)
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 12))
                .tint(.primary)
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
    
    private var cover: some View {
        VStack {
            if viewModel.showPoster || store.usePostersAsCover {
                posterCover
            } else {
                HeroImage(url: viewModel.content?.cardImageLarge,
                          title: title)
                .overlay {
                    ZStack {
                        Rectangle().fill(.ultraThinMaterial)
                        Image(systemName: animationImage)
                            .symbolRenderingMode(.multicolor)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120, alignment: .center)
                            .scaleEffect(animateGesture ? 1.1 : 1)
                    }
                    .opacity(animateGesture ? 1 : 0)
                }
                .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
                .shadow(radius: DrawingConstants.shadowRadius)
                .padding(.top)
                .padding(.bottom, 8)
                .accessibilityElement(children: .combine)
                .accessibility(hidden: true)
                .onTapGesture(count: 2) {
                    animate(for: store.gesture)
                    viewModel.update(store.gesture)
                }
            }
            Text(title)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .font(.title2)
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.bottom, 4)
                .onDisappear {
                    navigationTitle = title
                }
            if let genres = viewModel.content?.itemGenres {
                if !genres.isEmpty {
                    Text(genres)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontDesign(.rounded)
                }
            }
            if let info = viewModel.content?.itemQuickInfo {
                if !info.isEmpty {
                    Text(info)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontDesign(.rounded)
                }
            }
        }
    }
    
    private var posterCover: some View {
        WebImage(url: viewModel.content?.posterImageMedium)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(.gray.gradient)
                    VStack {
                        Text(title)
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .frame(width: 200, height: 300)
                            .padding()
                        Image(systemName: type == .tvShow ? "tv" : "film")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                        
                    }
                    .padding()
                }
            }
            .overlay {
                ZStack {
                    Rectangle().fill(.thinMaterial)
                    Image(systemName: animationImage)
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120, alignment: .center)
                        .scaleEffect(animateGesture ? 1.1 : 1)
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .aspectRatio(contentMode: .fill)
            .frame(width: 200, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .onTapGesture(count: 2) {
                animate(for: store.gesture)
                viewModel.update(store.gesture)
            }
            .shadow(radius: 12)
            .padding()
            .accessibility(hidden: true)
    }
    
    private func animate(for type: UpdateItemProperties) {
        switch type {
        case .watched: animationImage = viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle"
        case .favorite: animationImage = viewModel.isFavorite ? "heart.slash.fill" : "heart.fill"
        case .pin: animationImage = viewModel.isPin ? "pin.slash" : "pin"
        case .archive: animationImage = viewModel.isArchive ? "archivebox.fill" : "archivebox"
        }
        withAnimation { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation { animateGesture = false }
        }
    }
    
    @ViewBuilder
    private func infoBox(item: ItemContent?, type: MediaType) -> some View {
        GroupBox("Information") {
            Section {
                infoView(title: NSLocalizedString("Original Title", comment: ""),
                         content: item?.originalItemTitle)
                if let numberOfSeasons = item?.numberOfSeasons, let numberOfEpisodes = item?.numberOfEpisodes {
                    infoView(title: NSLocalizedString("Overview", comment: ""),
                             content: "\(numberOfSeasons) Seasons • \(numberOfEpisodes) Episodes")
                }
                infoView(title: NSLocalizedString("Run Time", comment: ""),
                         content: item?.itemRuntime)
                if type == .movie {
                    if let theatricalStringDate = item?.itemTheatricalString {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Release Date")
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                Text(theatricalStringDate)
                                    .lineLimit(1)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .accessibilityElement(children: .combine)
                            Spacer()
                        }
                        .padding([.horizontal, .top], 2)
                        .onTapGesture {
                            showReleaseDateInfo.toggle()
                        }
                    }
                    
                } else {
                    infoView(title: NSLocalizedString("First Air Date",
                                                      comment: ""),
                             content: item?.itemFirstAirDate)
                }
                infoView(title: NSLocalizedString("Ratings Score", comment: ""),
                         content: item?.itemRating)
                infoView(title: NSLocalizedString("Status",
                                                  comment: ""),
                         content: item?.itemStatus.localizedTitle)
                infoView(title: NSLocalizedString("Genres", comment: ""),
                         content: item?.itemGenres)
                infoView(title: NSLocalizedString("Region of Origin",
                                                  comment: ""),
                         content: item?.itemCountry)
                if let companies = item?.itemCompanies, let company = item?.itemCompany {
                    if !companies.isEmpty {
                        NavigationLink(value: companies) {
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("Production Companies")
                                            .font(.caption)
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                    }
                                    Text(company)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .accessibilityElement(children: .combine)
                                Spacer()
                            }
                            .padding([.horizontal, .top], 2)
                        }
#if os(macOS)
                        .buttonStyle(.link)
#endif
                    }
                } else {
                    infoView(title: NSLocalizedString("Production Company",
                                                      comment: ""),
                             content: item?.itemCompany)
                }
            }
        }
        .groupBoxStyle(TransparentGroupBox())
    }
    
    @ViewBuilder
    private func infoView(title: String, content: String?) -> some View {
        if let content {
            if !content.isEmpty {
                HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(.caption)
                        Text(content)
                            .multilineTextAlignment(.leading)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    Spacer()
                }
                .padding([.horizontal, .top], 2)
            } else { EmptyView() }
        } else {
            EmptyView()
        }
    }
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 12
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 12
}
#endif
