//
//  PersonCircleView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonCircleView: View {
    let person: Person
    var body: some View {
        NavigationLink(value: person) {
            WebImage(url: person.personImage)
                .resizable()
                .placeholder {
                    VStack {
                        Image(systemName: "person")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50, alignment: .center)
                            .foregroundColor(.white)
                            .opacity(0.9)
                    }
                    .frame(width: DrawingConstants.profileWidth,
                           height: DrawingConstants.profileHeight)
                    .background(Color.gray.gradient)
                    .clipShape(Circle())
                }
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: DrawingConstants.profileWidth,
                       height: DrawingConstants.profileHeight)
                .transition(.opacity)
        }
        .clipShape(Circle())
        .buttonStyle(.card)
    }
}

struct PersonCircleView_Previews: PreviewProvider {
    static var previews: some View {
        PersonCircleView(person: Person.previewCast)
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 220
    static let profileHeight: CGFloat = 220
    static let lineLimit: Int = 1
}
