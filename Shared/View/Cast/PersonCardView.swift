//
//  PersonCardView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/07/22.
//

import SwiftUI
import SDWebImageSwiftUI

/// This view is responsible for displaying a given person
/// in a card view, with its name, role, and image.
struct PersonCardView: View {
    let person: Person
    var body: some View {
        ZStack {
            WebImage(url: person.personImage)
                .placeholder {
                    Color.secondary
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
            Rectangle().fill(.ultraThinMaterial)
            Color.black.opacity(0.4)
            WebImage(url: person.personImage, options: .highPriority)
                .placeholder {
                    ZStack {
                        Rectangle().fill(.secondary)
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50, alignment: .center)
                            .foregroundColor(.white)
                        PersonNameCredits(person: person)
                    }
                    .frame(width: DrawingConstants.profileWidth,
                           height: DrawingConstants.profileHeight)
                    .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius,
                                                style: .continuous))
                }
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
            if person.personImage != nil {
                PersonNameCredits(person: person)
            }
        }
        .frame(width: DrawingConstants.profileWidth,
               height: DrawingConstants.profileHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius,
                                    style: .continuous))
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


struct PersonCardView_Previews: PreviewProvider {
    static var previews: some View {
        PersonCardView(person: Credits.previewCast)
    }
}
