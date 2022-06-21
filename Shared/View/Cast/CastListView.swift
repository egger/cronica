//
//  CastListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastListView: View {
    let credits: Credits?
    var body: some View {
        if let credits {
            VStack(alignment: .leading) {
                HStack {
                    Text("Cast & Crew")
                        .padding([.horizontal, .top])
                    Spacer()
                }
                .unredacted()
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack {
                        ForEach(credits.cast.prefix(10)) { cast in
                            NavigationLink(value: cast) {
                                ImageView(person: cast)
                                    .shadow(radius: DrawingConstants.shadowRadius)
                                    .padding(.leading, cast.id == self.credits?.cast.first!.id ? 16 : 0)
                                    .contextMenu {
                                        ShareLink(item: URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(cast.id)")!)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                        ForEach(credits.crew.filter { $0.personRole == "Director" }) { director in
                            NavigationLink(value: director) {
                                ImageView(person: director)
                                    .shadow(radius: DrawingConstants.shadowRadius)
                                    .contextMenu {
                                        ShareLink(item: URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(director.id)")!)
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding([.top, .bottom])
                    .padding(.trailing)
                })
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
    let person: Person
    var body: some View {
        AsyncImage(url: person.personImage,
                   transaction: Transaction(animation: .easeInOut)) { phase in
            if let image = phase.image {
                ZStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Rectangle().fill(.ultraThinMaterial)
                    Color.black.opacity(0.4)
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .mask(
                            LinearGradient(gradient: Gradient(stops: [
                                .init(color: .black, location: 0),
                                .init(color: .black, location: 0.5),
                                .init(color: .black.opacity(0), location: 1)
                            ]), startPoint: .top, endPoint: .bottom)
                        )
                        .transition(.opacity)
                    PersonNameCredits(person: person)
                }
            } else if phase.error != nil {
                Rectangle().redacted(reason: .placeholder)
            } else {
                ZStack {
                    Rectangle().fill(.secondary)
                    Image(systemName: "person")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50, alignment: .center)
                        .foregroundColor(.white)
                    PersonNameCredits(person: person)
                }
            }
        }
        .frame(width: DrawingConstants.profileWidth,
               height: DrawingConstants.profileHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius,
                                    style: .continuous))
        .padding(2)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 2
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}

private struct PersonNameCredits: View {
    let person: Person
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(person.name)
                    .font(.callout)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .lineLimit(DrawingConstants.lineLimit)
                    .padding(.leading, 6)
                Spacer()
            }
            HStack {
                Text(person.personRole ?? " ")
                    .foregroundColor(.white)
                    .font(.caption)
                    .lineLimit(DrawingConstants.lineLimit)
                    .padding(.leading, 6)
                Spacer()
            }
        }
        .padding(.bottom)
    }
}
