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
                            }
                            .buttonStyle(.plain)
                        }
                        ForEach(credits.crew.filter { $0.personRole == "Director" }) { director in
                            NavigationLink(value: director) {
                                ImageView(person: director)
                                    .shadow(radius: DrawingConstants.shadowRadius)
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
        ZStack {
            AsyncImage(url: person.personImage,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
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
                } else if phase.error != nil {
                    Rectangle().redacted(reason: .placeholder)
                } else {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Image(systemName: "person")
                                       .imageScale(.large)
                                       .foregroundColor(.secondary)
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Text(person.name)
                        .font(.callout)
                        .foregroundColor(.primary)
                        .lineLimit(DrawingConstants.lineLimit)
                        .padding(.leading, 6)
                    Spacer()
                }
                HStack {
                    Text(person.personRole ?? "")
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.leading, 6)
                    Spacer()
                }
            }
            .padding(.bottom)
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
    static let shadowRadius: CGFloat = 2.5
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}
