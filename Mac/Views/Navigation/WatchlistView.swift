//
//  WatchlistView.swift
//  Mac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @StateObject private var settings = SettingsStore.shared
    @State private var showListSelection = false
    @State private var navigationTitle = NSLocalizedString("Watchlist", comment: "")
    @State private var selectedList: CustomList?
    @State private var displayList = false
    @State private var isRotating = 0.0
    var body: some View {
        NavigationStack {
            VStack {
                if selectedList != nil {
                    CustomWatchlist(selectedList: $selectedList)
                } else {
                    DefaultWatchlist()
                }
            }
            .navigationTitle("")
            .onChange(of: selectedList, perform: { newValue in
                if let newValue {
                    navigationTitle = newValue.itemTitle
                } else {
                    navigationTitle = NSLocalizedString("Watchlist", comment: "")
                }
            })
            .sheet(isPresented: $showListSelection) {
                SelectListView(selectedList: $selectedList,
                               navigationTitle: $navigationTitle,
                               showListSelection: $showListSelection)
                .frame(width: 480, height: 400, alignment: .center)
            }
            .navigationDestination(for: WatchlistItem.self) { item in
                ItemContentDetailsView(id: item.itemId, title: item.itemTitle, type: item.itemMedia)
            }
            .navigationDestination(for: ItemContent.self) { item in
                ItemContentDetailsView(id: item.id, title: item.itemTitle, type: item.itemContentMedia)
            }
            .navigationDestination(for: [String:[ItemContent]].self) { item in
                let keys = item.map { (key, value) in key }
                let value = item.map { (key, value) in value }
                ItemContentCollectionDetails(title: keys[0], items: value[0])
            }
            .navigationDestination(for: [Person].self) { items in
                DetailedPeopleList(items: items)
            }
            .navigationDestination(for: ProductionCompany.self) { item in
                CompanyDetails(company: item)
            }
            .navigationDestination(for: [ProductionCompany].self) { item in
                CompaniesListView(companies: item)
            }
            .toolbar {
                // Acts like a navigationTitle
                ToolbarItem(placement: .navigation) {
                    WatchlistTitle(navigationTitle: $navigationTitle, showListSelection: $showListSelection)
                }
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
    }
}
