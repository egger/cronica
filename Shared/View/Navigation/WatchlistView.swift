//
//  WatchListView.swift
//  Story
//
//  Created by Alexandre Madeira on 15/01/22.
//
import SwiftUI

struct WatchlistView: View {
    static let tag: Screens? = .watchlist
    @StateObject private var settings = SettingsStore.shared
    @State private var showListSelection = false
    @State private var navigationTitle = NSLocalizedString("Watchlist", comment: "")
    @State private var selectedList: CustomList?
    @State private var displayList = false
    @State private var isRotating = 0.0
    var body: some View {
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
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .navigationDestination(for: WatchlistItem.self) { item in
#if os(macOS)
#else
            ItemContentDetails(title: item.itemTitle, id: item.itemId, type: item.itemMedia)
#endif
        }
        .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
#else
            ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
        }
        .navigationDestination(for: Person.self) { person in
            PersonDetailsView(title: person.name, id: person.id)
        }
        .navigationDestination(for: [String:[ItemContent]].self) { item in
            let keys = item.map { (key, _) in key }
            let value = item.map { (_, value) in value }
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
        .sheet(isPresented: $showListSelection, content: {
            SelectListView(selectedList: $selectedList,
                           navigationTitle: $navigationTitle,
                           showListSelection: $showListSelection)
            .presentationDetents([.medium])
        })
        .toolbar {
            // Acts like a navigationTitle
            ToolbarItem(placement: .principal) {
                HStack {
                    Text(navigationTitle)
                        .fontWeight(Font.Weight.semibold)
                        .lineLimit(1)
                        .foregroundColor(showListSelection ? .secondary : nil)
                    Image(systemName: "chevron.down")
                        .fontWeight(.bold)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isRotating))
                        .task(id: showListSelection, {
                            withAnimation(Animation.easeInOut(duration: 0.1)) {
                                if showListSelection {
                                    isRotating = -180.0
                                } else {
                                    isRotating = 0.0
                                }
                            }
                        })
//                        .onChange(of: showListSelection) { value in
//                            withAnimation(Animation.easeInOut(duration: 0.1)) {
//                                if value {
//                                    isRotating = -180.0
//                                } else {
//                                    isRotating = 0.0
//                                }
//                            }
//                        }
                }
                .onTapGesture {
                    showListSelection.toggle()
                }
            }
        }
    }
}

struct WatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
