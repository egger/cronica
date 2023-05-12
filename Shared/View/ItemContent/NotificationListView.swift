//
//  NotificationListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 25/09/22.
//

import SwiftUI

#if os(iOS) || os(macOS)
struct NotificationListView: View {
    @Binding var showNotification: Bool
    @State private var hasLoaded = false
    @State private var items = [ItemContent]()
    @State private var deliveredItems = [ItemContent]()
    var body: some View {
        NavigationStack {
            Form {
                if hasLoaded {
                    List {
                        deliveredItemsView
                        upcomingItemsView
                    }
                } else {
                    CenterHorizontalView { ProgressView("Loading") }
                }
            }
            .navigationTitle("Notifications")
#if os(macOS)
            .formStyle(.grouped)
#elseif os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done", action: dismiss) }
#else
                Button("Done", action: dismiss)
#endif
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia, handleToolbar: true)
            }
            .navigationDestination(for: Person.self) { item in
                PersonDetailsView(title: item.name, id: item.id)
            }
            .onAppear(perform: load)
        }
    }
    
    @ViewBuilder
    private var deliveredItemsView: some View {
        if !deliveredItems.isEmpty {
            Section("Recent Notifications") {
                ForEach(deliveredItems.sorted(by: { $0.itemTitle < $1.itemTitle })) { item in
                    ItemContentRow(item: item)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                removeDelivered(id: item.itemContentID, for: item.id)
                            } label: {
                                Label("Remove Notification", systemImage: "bell.slash.circle.fill")
                            }
                        }
                }
            }
        }
    }
    
    @ViewBuilder
    private var upcomingItemsView: some View {
        if items.isEmpty {
            CenterHorizontalView {
                Text("No notifications")
                    .padding()
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        } else {
            Section("Upcoming Notifications") {
                ForEach(items.sorted(by: { $0.itemTitle < $1.itemTitle })) { item in
                    ItemContentRow(item: item)
                        .onAppear {
                            let isStillSaved = PersistenceController.shared.isItemSaved(id: item.itemContentID)
                            if !isStillSaved {
                                NotificationManager.shared.removeNotification(identifier: item.itemContentID)
                            }
                        }
                }
            }
        }
    }
    
    private func dismiss() { showNotification.toggle() }
    
    private func load() {
        Task {
            items = await NotificationManager.shared.fetchUpcomingNotifications() ?? []
            deliveredItems = await NotificationManager.shared.fetchDeliveredNotifications()
            DispatchQueue.main.async { withAnimation { self.hasLoaded = true } }
        }
    }
    
    private func removeDelivered(id: String, for content: Int) {
        NotificationManager.shared.removeDeliveredNotification(identifier: id)
        withAnimation { items.removeAll(where: { $0.id == content }) }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationListView(showNotification: .constant(true))
    }
}
#endif
