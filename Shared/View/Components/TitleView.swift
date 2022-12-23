//
//  TitleView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/04/22.
//

import SwiftUI

struct TitleView: View {
    let title: String
    let subtitle: String
    let image: String
    var showChevron = false
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                        .padding([.top, .leading])
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
#if os(tvOS)
                        .font(.callout)
#else
                        .font(.title2)
#endif
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.top)
                            .accessibilityHidden(true)
                    }
                }
                if !subtitle.isEmpty {
                    HStack {
                        Text(NSLocalizedString(subtitle, comment: ""))
                            .foregroundColor(.secondary)
                            .padding(.leading)
                            .fontDesign(.rounded)
#if os(tvOS)
                            .font(.caption)
#else
                            .font(.callout)
#endif
                    }
                }
            }
            Spacer()
            Image(systemName: image)
                .foregroundColor(.secondary)
                .padding([.top, .horizontal])
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "Coming Soon", subtitle: "From Watchlist", image: "rectangle.stack")
    }
}
