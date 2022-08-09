//
//  ListItemsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/08/22.
//

import SwiftUI
import CoreData
import Foundation


@MainActor
class TableListViewModel: ObservableObject {
    @Published var items = [WatchlistItem]()
    private let context = PersistenceController.shared
    
    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \WatchlistItem.title, ascending: true)],
//        animation: .default)
    //var items: FetchedResults<WatchlistItem>
    @Published private var query = ""
     var filteredMovieItems: [WatchlistItem] {
        return items.filter { ($0.title?.localizedStandardContains(query))! as Bool }
    }
    
    
    func fetch(filter: DefaultListItems) {
        let request: NSFetchRequest<WatchlistItem> = WatchlistItem.fetchRequest()
        let list = try? self.context.container.viewContext.fetch(request)
        
        if let list {
            switch filter {
            case .movies:
                //items.filter { $0.isMovie }
                items.append(contentsOf: list.filter { $0.isMovie })
            case .shows:
               // items.filter { $0.isTvShow }
                items.append(contentsOf: list.filter { $0.isTvShow })
            case .upcoming:
                //items.filter { $0.isUpcomingMovie || $0.isUpcomingTvShow }
                items.append(contentsOf: list.filter { $0.isUpcomingMovie || $0.isUpcomingTvShow })
            case .production:
                //items.filter { $0.isInProduction }
                items.append(contentsOf: list.filter { $0.isInProduction })
            case .favorites:
                //items.filter { $0.isFavorite }
                items.append(contentsOf: list.filter { $0.isFavorite })
            case .watched:
                //items.filter { $0.isWatched }
                items.append(contentsOf: list.filter { $0.isWatched })
            case .unwatched:
                //items.filter { !$0.isWatched }
                items.append(contentsOf: list.filter { !$0.isWatched })
            }
        }
        
        
    }
}



enum DefaultListItems: String, Identifiable, Hashable, CaseIterable {
    var id: String { rawValue }
    case movies, shows, upcoming, production, favorites, watched, unwatched
    
    var title: String {
        switch self {
        case .movies:
            return "Movies"
        case .shows:
            return "Shows"
        case .upcoming:
            return "Upcoming"
        case .production:
            return "In Production"
        case .favorites:
            return "Favorites"
        case .watched:
            return "Watched"
        case .unwatched:
            return "Unwatched"
        }
    }
}
