//
//  CastListView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct CastListView: View {
    let credits: [Person]?
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Cast & Crew")
                    .padding([.horizontal, .top])
                Spacer()
            }
            .unredacted()
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let credits {
                        ForEach(credits.prefix(10)) { cast in
                            NavigationLink(destination: CastDetailsView(title: cast.name, id: cast.id)) {
                                ImageView(person: cast)
                                    .padding(.leading, cast.id == self.credits!.first!.id ? 16 : 0)
                            }
                            .buttonStyle(.plain)
                        }
                        ForEach(credits.filter { $0.personRole == "Director" }) { director in
                            NavigationLink(destination: CastDetailsView(title: director.name, id: director.id)) {
                                ImageView(person: director)
                            }
                            .buttonStyle(.plain)
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
        CastListView(credits: nil)
        ImageView(person: Credits.previewCast)
    }
}

private struct ImageView: View {
    let person: Person
    var body: some View {
        ZStack {
            AsyncImage(url: person.personImage,
                       transaction: Transaction(animation: .easeInOut)) { phase in
                if let image = phase.image {
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
                        .foregroundColor(.white)
                        .lineLimit(DrawingConstants.lineLimit)
                        .padding(.leading, 6)
                        .padding(.bottom, 1)
                    Spacer()
                }
                if !person.personRole.isEmpty {
                    HStack {
                        Text(person.personRole!)
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
