//
//  WatchlistPosterSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct WatchlistPosterSection: View {
    private let context = PersistenceController.shared
    let items: [WatchlistItem]
    let title: String
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        if !items.isEmpty {
            ScrollView {
                LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.posterColumns,
                          spacing: settings.isCompactUI ? 10 : 20) {
                    Section {
                        ForEach(items, id: \.itemContentID) { item in
                            WatchlistItemPoster(content: item)
                                .buttonStyle(.plain)
                        }
                        .onDelete(perform: delete)
                    } header: {
                        HStack(alignment: .firstTextBaseline) {
                            Text(NSLocalizedString(title, comment: ""))
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .textCase(.uppercase)
                            Spacer()
                            let formatString = NSLocalizedString("items count", comment: "")
                            let result = String(format: formatString, items.count)
                            Text(result)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .textCase(.uppercase)
                        }
                        .padding(.horizontal)
                    } 
                }.padding(.all, settings.isCompactUI ? 10 : nil)
            }
        } else {
            CenterHorizontalView {
                Text("This list is empty.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
    }
    
    private func delete(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
        }
    }
}

struct WatchlistPosterSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistPosterSection(items: [.example], title: "Preview")
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
    static let columns = [GridItem(.adaptive(minimum: 240))]
#elseif os(tvOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 260))]
    static let columns = [GridItem(.adaptive(minimum: 440))]
#else
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
    static let columns  = [GridItem(.adaptive(minimum: 160))]
    static let spacing: CGFloat = 20
#endif
    static let compactColumns = [GridItem(.adaptive(minimum: 80))]
}
