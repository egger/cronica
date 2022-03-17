//
//  CardListView.swift
//  Story (tvOS)
//
//  Created by Alexandre Madeira on 13/03/22.
//

import SwiftUI

struct CardListView: View {
    let style: StyleType
    let type: MediaType
    let title: String
    let items: [Content]
    var body: some View {
        if !items.isEmpty {
            Section {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(items) { item in
                            NavigationLink(destination: DetailsView(title: item.itemTitle, id: item.id, type: item.itemContentMedia)) {
                                Button {
                                    
                                } label: {
                                    AsyncImage(url: item.cardImageLarge) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        ProgressView(item.itemTitle)
                                    }
                                }
                                .buttonStyle(CardButtonStyle())
                                .frame(width: 400, height: 320)
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.headline)
                        .padding([.horizontal, .top])
                    Spacer()
                }
                HStack {
                    Text(NSLocalizedString(type.title, comment: ""))
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .padding(.horizontal)
                    Spacer()
                }
            }
        } else {
            EmptyView()
        }
    }
}

//struct CardListView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardListView()
//    }
//}

private struct DrawingConstants {
    static let cardWidth: CGFloat = 380
    static let cardHeight: CGFloat = 260
    static let cardRadius: CGFloat = 12
}
