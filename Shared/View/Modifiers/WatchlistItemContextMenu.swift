//
//  WatchlistItemContextMenu.swift
//  Shared
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistItemContextMenu: ViewModifier {
    let item: WatchlistItem
    @Binding var isWatched: Bool
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    @Binding var isArchive: Bool
    private let context = PersistenceController.shared
    private let notification = NotificationManager.shared
    @State private var showDeleteConfirmation = false
    @AppStorage("primaryLeftSwipe") private var primaryLeftSwipe: SwipeGestureOptions = .markWatch
    @AppStorage("secondaryLeftSwipe") private var secondaryLeftSwipe: SwipeGestureOptions = .markFavorite
    @AppStorage("primaryRightSwipe") private var primaryRightSwipe: SwipeGestureOptions = .delete
    @AppStorage("secondaryRightSwipe") private var secondaryRightSwipe: SwipeGestureOptions = .markArchive
    @AppStorage("allowFullSwipe") private var allowFullSwipe = false
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CustomList.title, ascending: true)],
        animation: .default)
    private var lists: FetchedResults<CustomList>
    func body(content: Content) -> some View {
#if os(watchOS)
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                watchedButton
                    .tint(item.isWatched ? .yellow : .green)
                    .disabled(item.isInProduction || item.isUpcoming)
                pinButton
                    .tint(item.isPin ? .gray : .teal)
                favoriteButton
                    .tint(item.isFavorite ? .orange : .blue)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                deleteButton
                archiveButton
            }
#elseif os(tvOS)
        return content
            .contextMenu {
                watchedButton
                favoriteButton
                pinButton
                archiveButton
                deleteButton
                Button("Cancel") { }
            }
#else
        return content
            .swipeActions(edge: .leading, allowsFullSwipe: allowFullSwipe) {
                primaryLeftSwipeActions
                secondaryLeftSwipeActions
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: allowFullSwipe) {
                primaryRightSwipeActions
                secondaryRightSwipeActions
            }
            .contextMenu {
                ShareLink(item: item.itemLink)
                watchedButton
                favoriteButton
                pinButton
                archiveButton
                addNote
                addToList
                Divider()
                deleteButton
            } preview: {
                previewView
            }
#endif
    }
    
    private var addNote: some View {
#if os(iOS)
        Button {
            
        } label: {
            if let note = item.note {
                if !note.isEmpty {
                    Label("openNote", systemImage: "note.text")
                }
            }
            Label("addNote", systemImage: "note.text.badge.plus")
        }
#else
        EmptyView()
#endif
    }
    
    private var addToList: some View {
#if os(iOS)
        Menu {
            ForEach(lists) { list in
                Button {
                    
                } label: {
                    if let addedList = item.list {
                        if list == addedList {
                            HStack {
                                Image(systemName: "checkmark")
                                Text(list.itemTitle)
                            }
                        }
                    } else {
                        Text(list.itemTitle)
                    }
                    Text(list.itemTitle)
//                    if let addedList = item.list {
//                        if let managedObjects = addedList as? Set<CustomList> {
//                            ForEach(managedObjects, id: \.self) { item in
//
//                            }
//                        }
//                        if list == addedList {
//                            HStack {
//                                Image(systemName: "checkmark")
//                                Text(list.itemTitle)
//                            }
//                        }
//                    } else {
//                        Text(list.itemTitle)
//                    }
                }
                
            }
        } label: {
            Label("addToList", systemImage: "rectangle.on.rectangle.angled")
        }
#else
        EmptyView()
#endif
    }
    
    private var share: some View {
#if os(iOS)
        ShareLink(item: item.itemUrlProxy)
#else
        EmptyView()
#endif
    }
    
    @ViewBuilder
    private var primaryLeftSwipeActions: some View {
        switch SettingsStore.shared.primaryLeftSwipe {
        case .markWatch:
            watchedButton
                .tint(item.isWatched ? .yellow : .green)
        case .markFavorite:
            favoriteButton
                .tint(item.isFavorite ? .orange : .purple)
        case .markPin:
            pinButton
                .tint(item.isPin ? .gray : .teal)
        case .markArchive:
            archiveButton
                .tint(item.isArchive ? .gray : .indigo)
        case .delete:
            deleteButton
        case .share:
            share
        }
    }
    
    @ViewBuilder
    private var secondaryLeftSwipeActions: some View {
        switch secondaryLeftSwipe {
        case .markWatch:
            watchedButton
                .tint(item.isWatched ? .yellow : .green)
        case .markFavorite:
            favoriteButton
                .tint(item.isFavorite ? .orange : .purple)
        case .markPin:
            pinButton
                .tint(item.isPin ? .gray : .teal)
        case .markArchive:
            archiveButton
                .tint(item.isArchive ? .gray : .indigo)
        case .delete:
            deleteButton
        case .share:
            share
        }
    }
    
    @ViewBuilder
    private var primaryRightSwipeActions: some View {
        switch primaryRightSwipe {
        case .markWatch:
            watchedButton
                .tint(item.isWatched ? .yellow : .green)
        case .markFavorite:
            favoriteButton
                .tint(item.isFavorite ? .orange : .purple)
        case .markPin:
            pinButton
                .tint(item.isPin ? .gray : .teal)
        case .markArchive:
            archiveButton
                .tint(item.isArchive ? .gray : .indigo)
        case .delete:
            deleteButton
        case .share:
            share
        }
    }
    
    @ViewBuilder
    private var secondaryRightSwipeActions: some View {
        switch secondaryRightSwipe {
        case .markWatch:
            watchedButton
                .tint(item.isWatched ? .yellow : .green)
        case .markFavorite:
            favoriteButton
                .tint(item.isFavorite ? .orange : .purple)
        case .markPin:
            pinButton
                .tint(item.isPin ? .gray : .teal)
        case .markArchive:
            archiveButton
                .tint(item.isArchive ? .gray : .indigo)
        case .delete:
            deleteButton
        case .share:
            share
        }
    }
    
    private var previewView: some View {
#if os(watchOS)
        EmptyView()
#else
        ZStack {
            WebImage(url: item.itemImage)
                .resizable()
                .placeholder {
                    ZStack {
                        Rectangle().fill(.gray.gradient)
                        Image(systemName: item.isMovie ? "film" : "tv")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }
                    .frame(width: 260, height: 180)
                }
                .aspectRatio(contentMode: .fill)
                .overlay {
                    VStack {
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
                                .frame(height: 70)
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
                            HStack {
                                Text(item.itemTitle)
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                }
        }
        .appTheme()
#endif
    }
    
    private var watchedButton: some View {
        Button(action: {
            withAnimation {
                withAnimation {
                    isWatched.toggle()
                }
                context.updateMarkAs(id: item.itemId, type: item.itemMedia, watched: !item.watched)
            }
            HapticManager.shared.successHaptic()
        }, label: {
            Label(item.isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: item.isWatched ? "minus.circle" : "checkmark.circle")
        })
    }
    
    private var favoriteButton: some View {
        Button {
            withAnimation {
                withAnimation {
                    isFavorite.toggle()
                }
                context.updateMarkAs(id: item.itemId, type: item.itemMedia, favorite: !item.favorite)
            }
            HapticManager.shared.successHaptic()
        } label: {
            Label(item.isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: item.isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        }
    }
    
    private var pinButton: some View {
        Button {
            PersistenceController.shared.updatePin(items: [item.notificationID])
            isPin.toggle()
            HapticManager.shared.successHaptic()
        } label: {
            Label(isPin ? "Unpin Item" : "Pin Item",
                  systemImage: isPin ? "pin.slash.fill" : "pin.fill")
        }
    }
    
    private var archiveButton: some View {
        Button {
            PersistenceController.shared.updateArchive(items: [item.notificationID])
            isArchive.toggle()
            HapticManager.shared.successHaptic()
        } label: {
            Label(isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: isArchive ? "archivebox.fill" : "archivebox")
        }
    }
    
    private var deleteButton: some View {
        Button(role: .destructive, action: {
            if item.notify {
                notification.removeNotification(identifier: item.notificationID)
            }
            withAnimation {
                context.delete(item)
            }
        }, label: {
            Label("Remove", systemImage: "trash")
        })
        .tint(.red)
    }
}
