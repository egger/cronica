//
//  TitleView.swift
//  Cronica (iOS)
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
                        .fontDesign(.rounded)
#if os(tvOS)
                        .font(.callout)
#else
                        .font(.title3)
#endif
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .fontDesign(.rounded)
                            .font(.callout)
                            .fontWeight(.regular)
                            .foregroundColor(.secondary)
                            .padding(.top)
                            .accessibilityHidden(true)
                    }
                }
                if let subtitle {
                    HStack {
                        Text(NSLocalizedString(subtitle, comment: ""))
                            .fontDesign(.rounded)
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

#Preview {
    TitleView(title: "Coming Soon", subtitle: "From Watchlist")
}
