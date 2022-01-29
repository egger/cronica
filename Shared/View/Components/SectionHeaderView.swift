//
//  SectionHeaderView.swift
//  Story
//
//  Created by Alexandre Madeira on 27/01/22.
//

import SwiftUI

struct SectionHeaderView: View {
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
                IconView(icon: "crown")
            case "up coming":
                IconView(icon: "theatermasks")
            case "now playing": 
                IconView(icon: "play.tv")
            case "top rated":
                IconView(icon: "star")
            case "airing today":
                IconView(icon: "calendar.badge.clock")
            case "on the air":
                IconView(icon: "tv")
            case "latest":
                IconView(icon: "flame")
            default:
                EmptyView()
            }
        }
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(title: "popular")
    }
}

struct IconView: View {
    let icon: String
    var body: some View {
        Image(systemName: icon)
            .foregroundColor(.secondary)
            .padding([.top, .horizontal])
    }
}
