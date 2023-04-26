//
//  WatchlistCardSection.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct WatchlistCardSection: View {
    private let context = PersistenceController.shared
    let items: [WatchlistItem]
    let title: String
    var body: some View {
        if !items.isEmpty {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: DrawingConstants.columns ))],
                          spacing: 20) {
#if os(tvOS)
                    ForEach(items, id: \.notificationID) { item in
                        WatchlistItemFrame(content: item)
                    }
#else
                    Section {
                        ForEach(items, id: \.notificationID) { item in
                            WatchlistItemFrame(content: item)
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
#endif
                }.padding()
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

struct WatchlistCardSection_Previews: PreviewProvider {
    static var previews: some View {
        WatchlistCardSection(items: [.example], title: "Preview")
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let columns: CGFloat = 240
#elseif os(tvOS)
    static let columns: CGFloat = 460
#else
    static let columns: CGFloat = UIDevice.isIPad ? 240 : 160
#endif
}
