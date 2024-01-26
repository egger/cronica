//
//  HorizontalWatchlistList.swift
//  Cronica
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct HorizontalWatchlistList: View {
    let items: [WatchlistItem]
    let title: String
    let subtitle: String?
    @StateObject private var settings = SettingsStore.shared
    @Binding var showPopup: Bool
    @Binding var popupType: ActionPopupItems?
    @Binding var shouldReload: Bool
    var body: some View {
        VStack {
#if os(tvOS) || os(visionOS)
            TitleView(title: title,
                      subtitle: subtitle)
            #if os(tvOS)
            .padding(.leading, 64)
            #endif
#else
            NavigationLink(value: [title:items]) {
                TitleView(title: title,
                          subtitle: subtitle,
                          showChevron: true)
            }
            .buttonStyle(.plain)
#endif
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
#if !os(tvOS)
                    if settings.listsDisplayType == .card {
                        LazyHStack {
                            ForEach(items) { item in
                                WatchlistItemCardView(content: item, showPopup: $showPopup, popupType: $popupType)
#if os(tvOS)
                                    .padding([.leading, .trailing], 2)
                                    .padding(.leading, item.id == self.items.first?.id ? 64 : 0)
                                    .padding(.trailing, item.id == self.items.last?.id ? 64 : 0)
                                    .padding(.vertical)
                                    .buttonStyle(.card)
#else
                                    .padding([.leading, .trailing], 4)
                                    .padding(.leading, item.id == self.items.first?.id ? 16 : 0)
                                    .padding(.trailing, item.id == self.items.last?.id ? 16 : 0)
                                    .padding(.top, 8)
                                    .padding(.bottom)
                                    .buttonStyle(.plain)
#endif
                            }
                        }
                    } else {
                        LazyHStack {
                            ForEach(items) { item in
                                WatchlistItemPosterView(content: item, showPopup: $showPopup, popupType: $popupType)
#if os(tvOS)
                                    .padding([.leading, .trailing], 2)
                                    .padding(.leading, item.id == self.items.first?.id ? 64 : 0)
                                    .padding(.trailing, item.id == self.items.last?.id ? 64 : 0)
                                    .buttonStyle(.card)
                                    .padding(.vertical)
#else
                                    .padding([.leading, .trailing], settings.isCompactUI ? 1 : 4)
                                    .padding(.leading, item.id == self.items.first?.id ? 16 : 0)
                                    .padding(.trailing, item.id == self.items.last?.id ? 16 : 0)
                                    .padding(.top, 8)
                                    .padding(.bottom)
#endif
                            }
                        }
                    }
#else
                    LazyHStack {
                        ForEach(items) { item in
                            WatchlistItemCardView(content: item, showPopup: $showPopup, popupType: $popupType)
                                .padding([.leading, .trailing], 2)
                                .padding(.leading, item.id == self.items.first?.id ? 64 : 0)
                                .padding(.trailing, item.id == self.items.last?.id ? 64 : 0)
                                .padding(.vertical)
                                .buttonStyle(.card)
                        }
                    }
#endif
                }
                .onChange(of: shouldReload) { _ in
                    guard let firstItem = items.first else { return }
                    withAnimation {
                        proxy.scrollTo(firstItem.id, anchor: .topLeading)
                    }
                }
            }
        }
    }
}

#Preview {
    HorizontalWatchlistList(items: [.example],
                            title: "Preview",
                            subtitle: "SwiftUI Preview",
                            showPopup: .constant(false), popupType: .constant(nil),
                            shouldReload: .constant(false))
}
