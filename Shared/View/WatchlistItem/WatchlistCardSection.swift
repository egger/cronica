//
//  WatchlistCardSection.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 20/12/22.
//

import SwiftUI

struct WatchlistCardSection: View {
    private let context = PersistenceController.shared
    let items: [WatchlistItem]
    let title: String
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    var body: some View {
        if !items.isEmpty { 
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: DrawingConstants.columns ))],
                          spacing: DrawingConstants.spacing) {
#if os(tvOS)
                    ForEach(items, id: \.itemContentID) { item in
                        WatchlistItemCardView(content: item, showPopup: $showPopup, popupType: $popupType)
                    }
#else
                    Section {
                        ForEach(items, id: \.itemContentID) { item in
                            WatchlistItemCardView(content: item, showPopup: $showPopup, popupType: $popupType)
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
                Text("emptyList")
                    .multilineTextAlignment(.center)
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

#Preview {
    WatchlistCardSection(items: [.example], title: "Preview", showPopup: .constant(false), popupType: .constant(nil))
}

private struct DrawingConstants {
#if os(macOS)
    static let columns: CGFloat = 240
    static let spacing: CGFloat = 20
#elseif os(tvOS)
    static let columns: CGFloat = 420
    static let spacing: CGFloat = 40
#else
    static let columns: CGFloat = UIDevice.isIPad ? 240 : 160
    static let spacing: CGFloat = 20
#endif
}
