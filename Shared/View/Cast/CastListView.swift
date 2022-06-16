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
                            NavigationLink(destination: CastDetailsView(title: cast.name, id: cast.id),
                                           label: {
                                ImageView(person: cast)
                                    .shadow(radius: DrawingConstants.shadowRadius)
                                    .padding(.leading, cast.id == self.credits?.cast.first!.id ? 16 : 0)
                            })
                            .buttonStyle(.plain)
                        }
                        ForEach(credits.crew.filter { $0.personRole == "Director" }) { director in
                            NavigationLink(destination: CastDetailsView(title: director.name, id: director.id),
                                           label: {
                                ImageView(person: director)
                                    .shadow(radius: DrawingConstants.shadowRadius)
                            })
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
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 60)
                    
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
            .padding(.bottom, 2)
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
