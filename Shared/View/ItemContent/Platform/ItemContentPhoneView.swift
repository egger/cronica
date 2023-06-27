//
//  ItemContentPhoneView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/05/23.
//

import SwiftUI
#if os(iOS)
struct ItemContentPhoneView: View {
    let title: String
    let type: MediaType
    let id: Int
    @Binding var showConfirmation: Bool
    @EnvironmentObject var viewModel: ItemContentViewModel
    @StateObject private var store = SettingsStore.shared
    @State private var animateGesture = false
    @State private var animationImage = ""
    var body: some View {
        VStack {
            cover
            
            DetailWatchlistButton()
                .keyboardShortcut("l", modifiers: [.option])
                .environmentObject(viewModel)

            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: title).padding()
            
            if let seasons = viewModel.content?.itemSeasons {
                SeasonList(showID: id, numberOfSeasons: seasons)
                    .padding([.top, .horizontal], .zero)
                    .padding(.bottom)
            }
            
            TrailerListView(trailers: viewModel.content?.itemTrailers)
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            HorizontalItemContentListView(items: viewModel.recommendations,
                                title: "Recommendations",
                                subtitle: "You may like",
                                addedItemConfirmation: $showConfirmation,
                                displayAsCard: true)
            
            infoBox(item: viewModel.content, type: type).padding()
            
            AttributionView().padding([.top, .bottom])
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var cover: some View {
        VStack {
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
            .padding(.vertical)
            .accessibilityElement(children: .combine)
            .accessibility(hidden: true)
            .onTapGesture(count: 2) {
                animate(for: store.gesture)
                viewModel.update(store.gesture)
            }
            if let genres = viewModel.content?.itemGenres {
                Text(genres)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if let info = viewModel.content?.itemQuickInfo {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
            }
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
    
    @ViewBuilder
    private func infoBox(item: ItemContent?, type: MediaType) -> some View {
        GroupBox {
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
                    infoView(title: NSLocalizedString("Release Date",
                                                      comment: ""),
                             content: item?.itemTheatricalString)
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
                                        .lineLimit(1)
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
        } label: {
            Label("Information", systemImage: "info")
                .unredacted()
        }
        .groupBoxStyle(TransparentGroupBox())
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

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 12
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 16
}

//@available(iOS 17, *)
//#Preview {
//    ItemContentPhoneView(title: "Preview", type: .movie, id: ItemContent.example.id, showConfirmation: .constant(false))
//}
#endif
