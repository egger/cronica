//
//  CastListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastListView: View {
    let credits: Credits
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Cast & Crew")
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    if credits.cast.isEmpty {
                        EmptyView()
                    } else {
                        ForEach(credits.cast.prefix(10)) { content in
                            NavigationLink(destination: CastDetailsView(title: content.name, id: content.id)) {
                                ImageView(name: content.name,
                                               characterOrJob: content.itemRole,
                                               url: content.itemImage)
                            }
                            .padding(.leading, content.id == self.credits.cast.first!.id ? 16 : 0)
                        }
                    }
                    if credits.crew.isEmpty {
                        EmptyView()
                    } else {
                        ForEach(credits.crew.filter { $0.itemRole == "Director" }) { content in
                            NavigationLink(destination: CastDetailsView(title: content.name, id: content.id)) {
                                ImageView(name: content.name, characterOrJob: content.itemRole, url: content.itemImage)
                            }
                        }
                    }
                }
                .padding([.top, .bottom])
                .padding(.trailing)
            }
        }
    }
}

struct PersonListView_Previews: PreviewProvider {
    static var previews: some View {
        CastListView(credits: Credits.previewCredits)
    }
}

private struct ImageView: View {
    let name: String
    let characterOrJob: String?
    let url: URL?
    var body: some View {
        ZStack {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Rectangle().fill(.ultraThickMaterial)
                    Color.black.opacity(0.6)
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .mask(
                            LinearGradient(gradient: Gradient(stops: [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.1),
                                .init(color: .black.opacity(0), location: 1)
                            ]), startPoint: .center, endPoint: .bottom)
                        )
                } else if phase.error != nil {
                    Rectangle().fill(.secondary)
                } else {
                    ZStack {
                        Rectangle().fill(.thickMaterial)
                        ProgressView()
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Text(name)
                        .foregroundColor(.white)
                        .lineLimit(DrawingConstants.lineLimit)
                        .padding(.leading, 6)
                        .padding(.bottom, 1)
                    Spacer()
                }
                if !characterOrJob.isEmpty {
                    HStack {
                        Text(characterOrJob!)
                            .foregroundColor(.white.opacity(0.8))
                            .font(.caption)
                            .lineLimit(1)
                            .padding(.leading, 6)
                            .padding(.bottom)
                        Spacer()
                    }
                }
            }
        }
        .frame(width: DrawingConstants.profileWidth,
               height: DrawingConstants.profileHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius,
                                    style: .continuous))
        .padding(2)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}
