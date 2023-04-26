//
//  NotificationListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/09/22.
//

import SwiftUI
import SDWebImageSwiftUI
#if os(iOS) || os(macOS)
struct NotificationListView: View {
    @Binding var showNotification: Bool
    @State private var hasLoaded = false
    @State private var items = [ItemContent]()
    @State private var deliveredItems = [ItemContent]()
    @AppStorage("isNotificationAllowed") var notificationAllowed = true
    var body: some View {
        NavigationStack {
            VStack {
                if hasLoaded {
                    List {
                        if items.isEmpty {
                            Text("No notifications")
                                .padding()
                                .font(.callout)
                                .foregroundColor(.secondary)
                        } else {
                            if !deliveredItems.isEmpty {
                                Section {
                                    ForEach(deliveredItems.sorted(by: { $0.itemTitle < $1.itemTitle })) { item in
                                        ItemContentItemView(item: item, subtitle: item.itemContentMedia.title)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    removeDelivered(id: item.itemNotificationID, for: item.id)
                                                } label: {
                                                    Label("Remove Notification", systemImage: "bell.slash.circle.fill")
                                                }
                                            }
                                    }
                                    .onDelete(perform: deleteDelivered)
                                } header: {
                                    Text("Recent Notifications")
                                }
                            }
                            
                            if !items.isEmpty {
                                Section {
                                    ForEach(items.sorted(by: { $0.itemTitle < $1.itemTitle })) { item in
                                        ItemContentItemView(item: item, subtitle: item.itemSearchDescription)
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    removeNotification(id: item.itemNotificationID, for: item.id)
                                                } label: {
                                                    Label("Remove Notification", systemImage: "bell.slash.circle.fill")
                                                }
                                            }
                                    }
                                    .onDelete(perform: delete)
                                } header: {
                                    Text("Upcoming Notifications")
                                } footer: {
                                    Text("\(items.count) upcoming notifications.")
                                        .padding(.bottom)
                                }
                            }
                        }
                    }
                } else {
                    CenterHorizontalView {
                        ProgressView("Loading")
                    }
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                if hasLoaded && !items.isEmpty {
#if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
#endif
                }
#if os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        showNotification.toggle()
                    }
                }
#else
                Button("Done") { showNotification.toggle() }
#endif
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.id, title: item.itemTitle,
                                       type: item.itemContentMedia, handleToolbarOnPopup: true)
#else
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
            }
            .navigationDestination(for: Person.self) { item in
                PersonDetailsView(title: item.name, id: item.id)
            }
            .onAppear {
                Task {
                    items = await NotificationManager.shared.fetchUpcomingNotifications() ?? []
                    deliveredItems = await NotificationManager.shared.fetchDeliveredNotifications()
                    withAnimation { hasLoaded = true }
                }
            }
        }
    }
    
    private func removeNotification(id: String, for content: Int) {
        NotificationManager.shared.removeNotification(identifier: id)
        withAnimation { items.removeAll(where: { $0.id == content }) }
    }
    
    private func removeDelivered(id: String, for content: Int) {
        NotificationManager.shared.removeDeliveredNotification(identifier: id)
        withAnimation { items.removeAll(where: { $0.id == content }) }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach { item in
                removeNotification(id: item.itemNotificationID, for: item.id)
            }
        }
    }
    
    private func deleteDelivered(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach { item in
                removeDelivered(id: item.itemNotificationID, for: item.id)
            }
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    @State private static var show = false
    static var previews: some View {
        NotificationListView(showNotification: $show)
    }
}

private struct ItemContentItemView: View {
    let item: ItemContent
    let subtitle: String
    @State private var isWatched = false
    @State private var showConfirmation = false
    @State private var isInWatchlist = true
    @State private var canReview = true
    @State private var showNote = false
    private let persistence = PersistenceController.shared
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                WebImage(url: item.cardImageMedium)
                    .placeholder {
                        ZStack {
                            Color.secondary
                            Image(systemName: "film")
                        }
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius))
                VStack(alignment: .leading) {
                    HStack {
                        Text(item.itemTitle)
                            .lineLimit(DrawingConstants.textLimit)
                    }
                    HStack {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .itemContentContextMenu(item: item,
                                    isWatched: $isWatched,
                                    showConfirmation: $showConfirmation,
                                    isInWatchlist: $isInWatchlist,
                                    canReview: $canReview,
                                    showNote: $showNote)
            .task {
                isWatched = persistence.isMarkedAsWatched(id: item.id, type: item.itemContentMedia)
            }
            .sheet(isPresented: $showNote) {
#if os(iOS) || os(macOS)
                NavigationStack {
                    if let content = try? persistence.fetch(for: Int64(item.id), media: item.itemContentMedia) {
                        WatchlistItemNoteView(item: content, showView: $showNote)
                    } else {
                        ProgressView()
                    }
                }
                .presentationDetents([.medium, .large])
#if os(macOS)
                .frame(width: 400, height: 400, alignment: .center)
#endif
#endif
            }
        }
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 70
    static let imageHeight: CGFloat = 50
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
#endif
