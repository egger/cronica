//
//  ExploreView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 30/04/22.
//

import SwiftUI

struct ExploreView: View {
    static let tag: Screens? = .explore
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
#endif
    @ViewBuilder
    var body: some View {
#if os(iOS)
        if horizontalSizeClass == .compact {
            NavigationView {
                details
            }
            .navigationViewStyle(.stack)
        } else {
           details
        }
#else
        details
#endif
    }
    
    var details: some View {
        VStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("Recommendations")
                            .font(.title)
                            .padding()
                        Spacer()
                    }
                    
                }
            }
            List {
                Section {
                    NavigationLink(destination: GenresListView(type: .movie)) {
                        Text("Movies")
                    }
                    NavigationLink(destination: GenresListView(type: .tvShow)) {
                        Text("TV Shows")
                    }
                } header: {
                    Text("Explore by Genres")
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Explore")
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
