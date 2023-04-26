//
//  ItemContentContextMenu.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentContextMenu: ViewModifier {
    let item: ItemContent
    @Binding var showConfirmation: Bool
    @Binding var isInWatchlist: Bool
    @Binding var isWatched: Bool
    @State private var isFavorite = false
    @State private var isPin = false
    @State private var isArchive = false
    private let context = PersistenceController.shared
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        animation: .default) private var lists: FetchedResults<CustomList>
    @State private var addedLists = [CustomList]()
    @State private var canReview = false
    @State private var showRemoveConfirmation = false
    func body(content: Content) -> some View {
#if os(watchOS)
#else
        return content
            .contextMenu {
                if isInWatchlist {
                    shareButton
                    watchedButton
                    favoriteButton
                    pinButton
                    archiveButton
                    addToList
                    Divider()
                    watchlistButton
                } else {
                    shareButton
                    Divider()
                    addAndMarkWatchedButton
                    watchlistButton
                }
            } preview: {
                ItemContentContextPreview(title: item.itemTitle,
                                          image: item.cardImageLarge,
                                          overview: item.itemOverview)
            }
            .task {
                if isInWatchlist {
                    canReview = true
                    isFavorite = context.isMarkedAsFavorite(id: item.id, type: item.itemContentMedia)
                    isPin = context.isItemPinned(id: item.id, type: item.itemContentMedia)
                    isArchive = context.isItemArchived(id: item.id, type: item.itemContentMedia)
                }
            }
            .onAppear {
                if addedLists.isEmpty {
                    addedLists = context.fetchLists(for: item.id, type: item.itemContentMedia)
                }
            }
            .alert("areYouSure", isPresented: $showRemoveConfirmation) {
                Button("Confirm") { remove() }
                Button("Cancel") { showRemoveConfirmation.toggle() }
            }
#endif
    }
    
    @ViewBuilder
    private var addToList: some View {
#if os(iOS) || os(macOS)
        if !lists.isEmpty {
            Menu {
                ForEach(lists) { list in
                    Button {
                        context.updateList(for: WatchlistItem.ID(item.id), type: item.itemContentMedia, to: list)
                        addedLists.append(list)
                    } label: {
                        if addedLists.contains(list) {
                            HStack {
#if os(iOS)
                                Image(systemName: "checkmark")
#endif
                                Text(list.itemTitle)
#if os(macOS)
                                Image(systemName: "checkmark")
#endif
                            }
                        } else {
                            Text(list.itemTitle)
                        }
                    }
                    
                }
            } label: {
                Label("addToList", systemImage: "rectangle.on.rectangle.angled")
            }
        } else {
            EmptyView()
        }
#else
        EmptyView()
#endif
    }
    
    private var addAndMarkWatchedButton: some View {
        Button {
            updateWatchlist()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                context.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: true)
                withAnimation {
                    isWatched.toggle()
                }
            }
        } label: {
            Label("addAndMarkWatchedButton", systemImage: "rectangle.badge.checkmark.fill")
        }
        
    }
    
    private var watchlistButton: some View {
        Button(role: isInWatchlist ? .destructive : nil) {
            if !isInWatchlist { HapticManager.shared.successHaptic() }
            updateWatchlist()
        } label: {
            Label(isInWatchlist ? "Remove from watchlist": "Add to watchlist",
                  systemImage: isInWatchlist ? "minus.square" : "plus.square")
#if os(macOS)
            .foregroundColor(isInWatchlist ? .red : nil)
            .labelStyle(.titleOnly)
#endif
        }
    }
    
    private var shareButton: some View {
#if os(tvOS)
        EmptyView()
#else
        ShareLink(item: item.itemURL)
#endif
    }
    
    private var watchedButton: some View {
        Button {
            context.updateMarkAs(id: item.id, type: item.itemContentMedia, watched: !isWatched)
            withAnimation {
                isWatched.toggle()
            }
            HapticManager.shared.successHaptic()
            if isWatched && item.itemContentMedia == .tvShow {
                Task {
                    await context.saveSeasons(for: item.id)
                }
            }
        } label: {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        }
    }
    
    private var favoriteButton: some View {
        Button {
            context.updateMarkAs(id: item.id, type: item.itemContentMedia, favorite: !isFavorite)
            withAnimation {
                isFavorite.toggle()
            }
            HapticManager.shared.successHaptic()
        } label: {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        }
    }
    
    private var pinButton: some View {
        Button {
            context.updatePin(items: [item.itemNotificationID])
            withAnimation {
                isPin.toggle()
            }
            HapticManager.shared.successHaptic()
        } label: {
            Label(isPin ? "Unpin Item" : "Pin Item",
                  systemImage: isPin ? "pin.slash" : "pin")
        }
    }
    
    private var archiveButton: some View {
        Button {
            context.updateArchive(items: [item.itemNotificationID])
            isArchive.toggle()
            HapticManager.shared.successHaptic()
        } label: {
            Label(isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: isArchive ? "archivebox.fill" : "archivebox")
        }
        
    }
    
    private func updateWatchlist() {
        if isInWatchlist {
            if SettingsStore.shared.showRemoveConfirmation {
                showRemoveConfirmation.toggle()
            } else {
                remove()
            }
        } else {
            add()
        }
    }
    
    private func remove() {
        do {
            let watchlistItem = try context.fetch(for: Int64(item.id), media: item.itemContentMedia)
            if let watchlistItem {
                if watchlistItem.notify {
                    NotificationManager.shared.removeNotification(identifier: watchlistItem.notificationID)
                }
                context.delete(watchlistItem)
                withAnimation {
                    isInWatchlist.toggle()
                }
            }
        } catch {
            let message = "Can't remove item from Watchlist, error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message,
                                                  for: "ItemContentContextMenu.updateWatchlist")
        }
    }
    
    private func add() {
        Task {
            do {
                let content = try await NetworkService.shared.fetchItem(id: item.id, type: item.itemContentMedia)
                context.save(content)
                registerNotification(content)
                displayConfirmation()
            } catch {
                if Task.isCancelled { return }
                CronicaTelemetry.shared.handleMessage(error.localizedDescription,
                                                      for: "ItemContentContextMenu.updateWatchlist")
                context.save(item)
                registerNotification(item)
                displayConfirmation()
            }
        }
    }
    
    private func registerNotification(_ item: ItemContent) {
        if item.itemCanNotify && item.itemFallbackDate.isLessThanTwoMonthsAway() {
            NotificationManager.shared.schedule(item)
        }
    }
    
    private func displayConfirmation() {
        withAnimation {
            showConfirmation.toggle()
            isInWatchlist.toggle()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation {
                showConfirmation = false
            }
        }
    }
}

private struct ItemContentContextPreview: View {
    let title: String
    let image: URL?
    let overview: String
    var body: some View {
#if os(iOS)
        ZStack {
            WebImage(url: image)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.regularMaterial)
                        Label(title, systemImage: "film")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    .frame(width: 260, height: 180)
                }
                .aspectRatio(contentMode: .fill)
                .overlay {
                    if image != nil {
                        VStack(alignment: .leading) {
                            Spacer()
                            ZStack(alignment: .bottom) {
                                Color.black.opacity(0.4)
                                    .frame(height: 70)
                                    .mask {
                                        LinearGradient(colors: [Color.black,
                                                                Color.black.opacity(0.924),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 100)
                                    .mask {
                                        VStack(spacing: 0) {
                                            LinearGradient(colors: [Color.black.opacity(0),
                                                                    Color.black.opacity(0.383),
                                                                    Color.black.opacity(0.707),
                                                                    Color.black.opacity(0.924),
                                                                    Color.black],
                                                           startPoint: .top,
                                                           endPoint: .bottom)
                                            .frame(height: 70)
                                            Rectangle()
                                        }
                                    }
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(title)
                                            .font(.callout)
                                            .foregroundColor(.white)
                                            .fontWeight(.semibold)
                                            .lineLimit(1)
                                            .padding(.horizontal)
                                            .padding(.bottom, 2)
                                        Spacer()
                                    }
                                    Text(overview)
                                        .lineLimit(2)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)
                                        .padding(.bottom, 16)
                                }
                            }
                        }
                    }
                }
        }
#endif
    }
}
