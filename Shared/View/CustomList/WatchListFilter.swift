//
//  WatchListFilter.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/05/23.
//

import SwiftUI

struct WatchListFilter: View {
    @Binding var selectedOrder: DefaultListTypes
    @Binding var showAllItems: Bool
    @Binding var mediaTypeFilter: MediaTypeFilters
    @Binding var showView: Bool
    var body: some View {
        Form {
            Section {
                Toggle("defaultWatchlistShowAllItems", isOn: $showAllItems)
                Picker("mediaTypeFilter", selection: $mediaTypeFilter) {
                    ForEach(MediaTypeFilters.allCases) { sort in
                        Text(sort.localizableTitle).tag(sort)
                    }
                }
                .disabled(!showAllItems)
#if os(iOS)
                .pickerStyle(.navigationLink)
#endif
            }
            Section {
                Picker("defaultWatchlistSmartFilters", selection: $selectedOrder) {
                    ForEach(DefaultListTypes.allCases) { sort in
                        Text(sort.title).tag(sort)
                    }
                }
#if os(iOS)
                .pickerStyle(.navigationLink)
#endif
                .disabled(showAllItems)
#if os(iOS)
                .pickerStyle(.navigationLink)
#endif
            }
        }
        .navigationTitle("defaultWatchlistFilters")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar {
            Button("Cancel") { showView.toggle() }
        }
    }
}

struct WatchListFilter_Previews: PreviewProvider {
    static var previews: some View {
        WatchListFilter(selectedOrder: .constant(.released),
                        showAllItems: .constant(false),
                        mediaTypeFilter: .constant(.noFilter),
                        showView: .constant(true))
    }
}
