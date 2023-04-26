//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//

import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @State private var showListSelection = false
    @State private var navigationTitle = NSLocalizedString("Watchlist", comment: "")
    @State private var selectedList: CustomList?
    var body: some View {
        VStack {
            if selectedList != nil {
                CustomWatchlist(selectedList: $selectedList)
            } else {
                DefaultWatchlist()
            }
        }
        .navigationTitle("")
        .onChange(of: selectedList) { newValue in
            if let newValue {
                navigationTitle = newValue.itemTitle
            } else {
                navigationTitle = NSLocalizedString("Watchlist", comment: "")
            }
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationDestination(for: WatchlistItem.self) { item in
#if os(macOS)
            ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
#else
            ItemContentDetails(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
#endif
        }
        .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
            ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
#else
            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
        }
        .navigationDestination(for: Person.self) { person in
#if os(tvOS)
#else
            PersonDetailsView(title: person.name, id: person.id)
#endif
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
#if os(tvOS)
#else
            ItemContentCollectionDetails(title: keys[0], items: value[0])
#endif
        }
        .navigationDestination(for: [Person].self) { items in
#if os(tvOS)
#else
            DetailedPeopleList(items: items)
#endif
        }
        .navigationDestination(for: ProductionCompany.self) { item in
#if os(tvOS)
#else
            CompanyDetails(company: item)
#endif
        }
        .navigationDestination(for: [ProductionCompany].self) { item in
#if os(tvOS)
#else
            CompaniesListView(companies: item)
#endif
        }
        .sheet(isPresented: $showListSelection) {
            SelectListView(selectedList: $selectedList,
                           navigationTitle: $navigationTitle,
                           showListSelection: $showListSelection)
            .presentationDetents([.medium, .large])
#if os(iOS)
            .appTheme()
#elseif os(macOS)
            .frame(width: 480, height: 400, alignment: .center)
#endif
        }
        .toolbar {
            // Acts like a navigationTitle
#if os(iOS)
            ToolbarItem(placement: .principal) {
                WatchlistTitle(navigationTitle: $navigationTitle, showListSelection: $showListSelection)
            }
#elseif os(macOS)
            ToolbarItem(placement: .navigation) {
                WatchlistTitle(navigationTitle: $navigationTitle, showListSelection: $showListSelection)
            }
#elseif os(tvOS)
            ToolbarItem(placement: .navigation) {
                Button {
                    showListSelection.toggle()
                } label: {
                    WatchlistTitle(navigationTitle: $navigationTitle, showListSelection: $showListSelection)
                }
                .buttonStyle(.plain)
            }
#endif
        }
    }
}

#if os(iOS) || os(macOS)
struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
#endif
