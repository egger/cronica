//
//  TitleView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/04/22.
//

import SwiftUI

struct TitleView: View {
    let title: String
    var subtitle: String?
    var showChevron = false
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                        .padding([.top, .leading])
                        .fontWeight(.semibold)
#if os(tvOS)
                        .font(.headline)
                        .foregroundColor(.secondary)
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
                if let subtitle {
                    HStack {
                        Text(NSLocalizedString(subtitle, comment: ""))
                            .foregroundColor(.secondary)
                            .padding(.leading)
#if os(tvOS)
                            .font(.caption)
#else
                            .font(.callout)
#endif
                    } 
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView(title: "Coming Soon", subtitle: "From Watchlist")
    }
}
