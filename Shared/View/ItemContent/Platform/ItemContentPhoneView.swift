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
                    .padding([.top, .horizontal], 0)
                    .padding(.bottom)
            }
            
            TrailerListView(trailers: viewModel.content?.itemTrailers)
            
            WatchProvidersList(id: id, type: type)
            
            CastListView(credits: viewModel.credits)
            
            ItemContentListView(items: viewModel.recommendations,
                                title: "Recommendations",
                                subtitle: "You may like",
                                addedItemConfirmation: $showConfirmation,
                                displayAsCard: true)
            
            InformationSectionView(item: viewModel.content, type: type).padding()
            
            AttributionView().padding([.top, .bottom])
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.automatic)
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
            if let info = viewModel.content?.itemInfo {
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
}

struct ItemContentPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentPhoneView(title: "Preview", type: .movie, id: ItemContent.example.id, showConfirmation: .constant(false))
    }
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 12
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 12
}
#endif
