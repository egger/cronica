//
//  SectionHeader.swift
//  Story
//
//  Created by Alexandre Madeira on 27/01/22.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .textCase(.uppercase)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding([.top, .horizontal])
            Spacer()
            switch title {
            case "popular":
                Image(systemName: "crown")
                    .foregroundColor(.secondary)
                    .padding([.top, .horizontal])
            case "up coming":
                Image(systemName: "theatermasks")
                    .foregroundColor(.secondary)
                    .padding([.top, .horizontal])
            case "now playing":
                Image(systemName: "play.tv")
                    .foregroundColor(.secondary)
                    .padding([.top, .horizontal])
            default:
                EmptyView()
            }
        }
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader(title: "popular")
    }
}
