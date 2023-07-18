//
//  ItemContentPadView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/05/23.
//

import SwiftUI
import SDWebImageSwiftUI
#if !os(tvOS)
/// The Details view for ItemContent for iPadOS and macOS, built with larger screen in mind.
struct ItemContentPadView: View {
    let id: Int
    let title: String
    let type: MediaType
    @Binding var showCustomList: Bool
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var animationImage = ""
    @State private var animateGesture = false
    @State private var showOverview = false
    @State private var showInfoBox = false
    @State private var showReleaseDateInfo = false
    @State private var isSideInfoPanelShowed = false
    @State private var popupType: ActionPopupItems?
    @StateObject private var store = SettingsStore.shared
    @Binding var showPopup: Bool
    var body: some View {
        VStack {
            header.padding(.leading)
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, showTitle: title, numberOfSeasons: seasons).padding(0)
            }
            
#if !os(tvOS)
            TrailerListView(trailers: viewModel.content?.itemTrailers)
#endif
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            HorizontalItemContentListView(items: viewModel.recommendations,
                                          title: "Recommendations",
                                          showPopup: $showPopup,
                                          popupType: $popupType,
                                          displayAsCard: true)
#if !os(tvOS)
            if showInfoBox {
                GroupBox("Information") {
                    QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                } 
                .padding()
                
            }
#endif
            
            AttributionView().padding([.top, .bottom])
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
        .navigationTitle(title)
#endif
        .task {
            if !isSideInfoPanelShowed && !showInfoBox { showInfoBox = true }
        }
    }
    
    private var header: some View {
        HStack {
            WebImage(url: viewModel.content?.posterImageMedium)
                .resizable()
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
                .frame(width: 300, height: 460)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onTapGesture(count: 2) {
                    animate(for: store.gesture)
                    viewModel.update(store.gesture)
                }
                .shadow(radius: 12)
                .padding()
                .accessibility(hidden: true)
            
            
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.title)
                    .padding(.bottom)
                HStack {
                    Text(viewModel.content?.itemOverview ?? "")
                        .lineLimit(10)
                        .onTapGesture {
                            showOverview.toggle()
                        }
                    Spacer()
                }
                .frame(maxWidth: 460)
                .padding(.bottom)
#if os(iOS) || os(macOS)
                .popover(isPresented: $showOverview) {
                    if let overview = viewModel.content?.itemOverview {
                        VStack {
                            ScrollView {
                                Text(overview)
                                    .padding()
                            }
                        }
                        .frame(minWidth: 200, maxWidth: 400, minHeight: 200, maxHeight: 300, alignment: .center)
                    }
                }
#endif
                
                // Actions
                HStack {
                    DetailWatchlistButton(showCustomList: $showCustomList)
                        .environmentObject(viewModel)
                    
                    if viewModel.isInWatchlist {
                        Button {
                            showCustomList.toggle()
                        } label: {
#if os(macOS)
                            Label("Lists", systemImage: "rectangle.on.rectangle.angled")
#else
                            VStack {
                                Image(systemName: "rectangle.on.rectangle.angled")
                                Text("Lists")
                                    .padding(.top, 2)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                            .frame(width: 60)
#endif
                        }
#if os(macOS)
                        .controlSize(.large)
#else
                        .controlSize(.small)
#endif
                        .buttonStyle(.bordered)
#if os(iOS)
                        .buttonBorderShape(.roundedRectangle(radius: 12))
#endif
                        .tint(.primary)
                        .padding(.leading)
                        Button {
                            animate(for: .watched)
                            viewModel.update(.watched)
                        } label: {
#if os(macOS)
                            Label("Watched", systemImage: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
#else
                            VStack {
                                Image(systemName: viewModel.isWatched ? "minus.circle" : "checkmark.circle")
                                Text("Watched")
                                    .padding(.top, 2)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .padding(.vertical, 4)
                            .frame(width: 60)
#endif
                        }
                        .keyboardShortcut("w", modifiers: [.option])
#if os(macOS)
                        .controlSize(.large)
#else
                        .controlSize(.small)
#endif
                        .buttonStyle(.bordered)
#if os(iOS)
                        .buttonBorderShape(.roundedRectangle(radius: 12))
#endif
                        .tint(.primary)
                        .padding(.leading)
                    }
                }
            }
            .frame(width: 360)
            
            ViewThatFits {
                QuickInformationView(item: viewModel.content, showReleaseDateInfo: $showReleaseDateInfo)
                    .frame(width: 280)
                    .padding(.horizontal)
                    .onAppear {
                        showInfoBox = false
                        isSideInfoPanelShowed = true
                    }
                    .onDisappear {
                        showInfoBox = true
                        isSideInfoPanelShowed = false
                    }
                VStack {
                    Text("")
                }
            }
            
            Spacer()
        }
    }
    
    private func animate(for type: UpdateItemProperties) {
        switch type {
        case .watched: animationImage = viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle"
        case .favorite: animationImage = viewModel.isFavorite ? "heart.slash.fill" : "heart.fill"
        case .pin: animationImage = viewModel.isPin ? "pin.slash" : "pin.fill"
        case .archive: animationImage = viewModel.isArchive ? "archivebox" : "archivebox.fill"
        }
        withAnimation { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation { animateGesture = false }
        }
    }
}
#endif
struct QuickInformationView: View {
    let item: ItemContent?
    @Binding var showReleaseDateInfo: Bool
    var body: some View {
        VStack(alignment: .leading) {
            infoView(title: NSLocalizedString("Original Title",
                                              comment: ""),
                     content: item?.originalItemTitle)
            infoView(title: NSLocalizedString("Run Time", comment: ""),
                     content: item?.itemRuntime)
            if let numberOfSeasons = item?.numberOfSeasons, let numberOfEpisodes = item?.numberOfEpisodes {
                infoView(title: NSLocalizedString("Overview",
                                                  comment: ""),
                         content: "\(numberOfSeasons) Seasons • \(numberOfEpisodes) Episodes")
            }
            if item?.itemContentMedia == .movie {
                if let theatricalStringDate = item?.itemTheatricalString {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Release Date")
                                    .font(.caption)
#if !os(tvOS)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
#endif
                            }
                            Text(theatricalStringDate)
                                .lineLimit(1)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .accessibilityElement(children: .combine)
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
            infoView(title: NSLocalizedString("Region of Origin",
                                              comment: ""),
                     content: item?.itemCountry)
            infoView(title: NSLocalizedString("Genres", comment: ""),
                     content: item?.itemGenres)
            if let companies = item?.itemCompanies, let company = item?.itemCompany {
                if !companies.isEmpty {
#if !os(tvOS)
                    NavigationLink(value: companies) {
                        companiesLabel(company: company)
                    }
                    .buttonStyle(.plain)
#else
                    companiesLabel(company: company)
#endif
                }
            } else {
                infoView(title: NSLocalizedString("Production Company",
                                                  comment: ""),
                         content: item?.itemCompany)
            }
            infoView(title: NSLocalizedString("Status",
                                              comment: ""),
                     content: item?.itemStatus.localizedTitle)
        }
        .sheet(isPresented: $showReleaseDateInfo) {
            DetailedReleaseDateView(item: item?.releaseDates?.results,
                                    dismiss: $showReleaseDateInfo)
#if os(macOS)
            .frame(width: 400, height: 300, alignment: .center)
#else
            .appTint()
            .appTheme()
#endif
        }
    }
    
    private func companiesLabel(company: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Production Company")
                        .font(.caption)
#if !os(tvOS)
                    Image(systemName: "chevron.right")
                        .font(.caption)
#endif
                }
                Text(company)
                    .lineLimit(1)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            Spacer()
        }
        .padding([.horizontal, .top], 2)
    }
    
    @ViewBuilder
    private func infoView(title: String, content: String?) -> some View {
        if let content {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.caption)
                    Text(content)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                Spacer()
            }
            .padding([.horizontal, .top], 2)
        } else {
            EmptyView()
        }
    }
}

