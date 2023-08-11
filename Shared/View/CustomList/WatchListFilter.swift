//
//  WatchListFilter.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/05/23.
//

import SwiftUI

struct WatchListFilter: View {
    @Binding var selectedOrder: SmartFiltersTypes
    @Binding var showAllItems: Bool
    @Binding var mediaTypeFilter: MediaTypeFilters
    @Binding var showView: Bool
    var body: some View {
        Form {
#if !os(tvOS)
			Section {
				Toggle("defaultWatchlistShowAllItems", isOn: $showAllItems)
				Picker("mediaTypeFilter", selection: $mediaTypeFilter) {
					ForEach(MediaTypeFilters.allCases) { sort in
						Text(sort.localizableTitle).tag(sort)
					}
				}
				.pickerStyle(.segmented)
				.disabled(!showAllItems)
			}
#endif
            Section {
                Picker(selection: $selectedOrder) {
                    ForEach(SmartFiltersTypes.allCases) { sort in
                        Text(sort.title).tag(sort)
                    }
                } label: {
                    EmptyView()
                }
                .disabled(showAllItems)
				.pickerStyle(.inline)
            }  header: {
                Text("defaultWatchlistSmartFilters")
#if os(iOS)
                    .foregroundColor(.secondary)
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
#if os(macOS)
        .formStyle(.grouped)
#endif
        .onChange(of: selectedOrder) { _ in
            showView = false
        }
        .onChange(of: showAllItems) { _ in
            if !showAllItems { showView = false }
        }
        .onChange(of: mediaTypeFilter) { _ in
            showView.toggle()
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
