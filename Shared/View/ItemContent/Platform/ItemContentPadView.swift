//
//  ItemContentPadView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

/// The Details view for ItemContent for iPadOS and macOS, built with larger screen in mind.
struct ItemContentPadView: View {
    let id: Int
    let title: String
    let type: MediaType
    @State private var showCustomList = false
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var animationImage = ""
    @State private var animateGesture = false
    @State private var showOverview = false
    @StateObject private var store = SettingsStore.shared
    @Binding var showConfirmation: Bool
    var body: some View {
        VStack {
            header
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, numberOfSeasons: seasons).padding(0)
            }
            
#if os(iOS) || os(macOS)
            TrailerListView(trailers: viewModel.content?.itemTrailers)
#endif
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            ItemContentListView(items: viewModel.recommendations,
                                title: "Recommendations",
                                subtitle: "You may like",
                                image: nil,
                                addedItemConfirmation: $showConfirmation,
                                displayAsCard: true)
            
            AttributionView().padding([.top, .bottom])
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#elseif os(macOS)
        .navigationTitle(title)
#endif
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
                .aspectRatio(contentMode: .fill)
#if os(macOS)
                .frame(width: 340, height: 500)
#else
                .frame(width: 300, height: 460)
#endif
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
                Text(viewModel.content?.itemInfo ?? "")
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                HStack {
                    Text(viewModel.content?.itemOverview ?? "")
                        .lineLimit(10)
                        .onTapGesture {
                            showOverview.toggle()
                        }
                    Spacer()
                }
                .frame(maxWidth: 400)
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
                    Button {
                        guard let item = viewModel.content else { return }
                        viewModel.updateWatchlist(with: item)
                    } label: {
                        Label(viewModel.isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                              systemImage: viewModel.isInWatchlist ? "minus.circle.fill" : "plus.circle.fill")
                    }
                    .tint(viewModel.isInWatchlist ? .red.opacity(0.8) : .black.opacity(0.8))
                    .disabled(viewModel.isLoading)
                    .buttonStyle(.borderedProminent)
#if os(iOS) || os(macOS)
                    .controlSize(.large)
                    .keyboardShortcut("l", modifiers: [.option])
#endif
#if os(iOS)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
#endif
                    .applyHoverEffect()
                    
                    if viewModel.isInWatchlist {
                        if let id = viewModel.content?.itemContentID {
                            Button {
                                showCustomList.toggle()
                            } label: {
                                Label("addToList", systemImage: "rectangle.on.rectangle.angled")
                                    .foregroundColor(.primary)
                            }
                            .labelStyle(.iconOnly)
#if os(iOS) || os(macOS)
                            .controlSize(.large)
#endif
                            .buttonStyle(.bordered)
#if os(iOS)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
#endif
                            .padding(.leading, 6)
                            .applyHoverEffect()
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
                        }
                    }
                }
            }
            .frame(width: 360)
            
            ViewThatFits {
                QuickInformationView(item: viewModel.content)
                    .frame(width: 260)
                    .padding(.trailing)
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
        case .pin: animationImage = viewModel.isPin ? "pin.slash" : "pin"
        case .archive: animationImage = viewModel.isArchive ? "archivebox.fill" : "archivebox"
        }
        withAnimation { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { animateGesture = false }
        }
    }
}

private struct QuickInformationView: View {
    let item: ItemContent?
    var body: some View {
        VStack(alignment: .leading) {
            InfoView(title: NSLocalizedString("Original Title",
                                              comment: ""),
                     content: item?.originalItemTitle)
            if let numberOfSeasons = item?.numberOfSeasons, let numberOfEpisodes = item?.numberOfEpisodes {
                InfoView(title: NSLocalizedString("Overview",
                                                  comment: ""),
                         content: "\(numberOfSeasons) Seasons • \(numberOfEpisodes) Episodes")
            }
            InfoView(title: NSLocalizedString("First Air Date",
                                              comment: ""),
                     content: item?.itemFirstAirDate)
            InfoView(title: NSLocalizedString("Region of Origin",
                                              comment: ""),
                     content: item?.itemCountry)
            InfoView(title: NSLocalizedString("Genres", comment: ""),
                     content: item?.itemGenres)
            if let companies = item?.itemCompanies, let company = companies.first {
                if !companies.isEmpty {
                    NavigationLink(value: companies) {
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Production Company")
                                        .font(.caption)
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                }
                                Text(company.name)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            Spacer()
                        }
                        .padding([.horizontal, .top], 2)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                InfoView(title: NSLocalizedString("Production Company",
                                                  comment: ""),
                         content: item?.itemCompany)
            }
            InfoView(title: NSLocalizedString("Status",
                                              comment: ""),
                     content: item?.itemStatus.localizedTitle)
        }
    }
}
