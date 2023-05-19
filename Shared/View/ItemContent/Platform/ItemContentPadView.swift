//
//  ItemContentPadView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

#if os(iOS)
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
            
            TrailerListView(trailers: viewModel.content?.itemTrailers)
            
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
        .navigationBarTitleDisplayMode(.inline)
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
                .frame(width: 340, height: 500)
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
                .popover(isPresented: $showOverview) {
                    if let overview = viewModel.content?.itemOverview {
                        VStack {
                            ScrollView {
                                Text(overview)
                                    .padding()
                            }
                        }
                        .frame(width: 400, height: 300, alignment: .center)
                    }
                }
                
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
                    .controlSize(.large)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .hoverEffect()
                    .keyboardShortcut("l", modifiers: [.option])
                   
                    if viewModel.isInWatchlist {
                        if let id = viewModel.content?.itemContentID {
                            Button {
                                showCustomList.toggle()
                            } label: {
                                Label("addToList", systemImage: "rectangle.on.rectangle.angled")
                                    .foregroundColor(.primary)
                            }
                            .labelStyle(.iconOnly)
                            .controlSize(.large)
                            .buttonStyle(.bordered)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.leading, 6)
                            .hoverEffect()
                            .sheet(isPresented: $showCustomList) {
                                NavigationStack {
                                    ItemContentCustomListSelector(contentID: id,
                                                                  showView: $showCustomList,
                                                                  title: title)
                                }
                                .presentationDetents([.medium, .large])
                                .presentationDragIndicator(.visible)
                            }
                            .keyboardShortcut("k", modifiers: [.option])
                        }
                    }
                }
            }
            .frame(minWidth: 400, maxWidth: 500)
            
            ViewThatFits {
                QuickInformationView(item: viewModel.content)
                    .frame(minWidth: 200)
                    .padding(.trailing)
                EmptyView()
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
            InfoView(title: NSLocalizedString("Overview",
                                              comment: ""),
                     content: item?.itemInfoTVShow)
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
#endif
