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
                .font(.headline)
                .foregroundColor(.secondary)
                .padding([.top, .horizontal])
            Spacer()
            switch title {
            case "Popular":
                IconView(icon: "crown")
            case "Up Coming":
                IconView(icon: "theatermasks")
            case "Now Playing":
                IconView(icon: "play.tv")
            case "Top Rated":
                IconView(icon: "star")
            case "Airing Today":
                IconView(icon: "calendar.badge.clock")
            case "On The Air":
                IconView(icon: "tv")
            case "Latest":
                IconView(icon: "flame")
            case "similarCastMovie":
                IconView(icon: "person.crop.rectangle.stack.fill")
            case "You may like":
                IconView(icon: "list.and.film")
            default:
                EmptyView()
            }
        }
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeaderView(title: "Popular")
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
