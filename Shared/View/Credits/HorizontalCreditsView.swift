//
//  HorizontalCreditsView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct HorizontalCreditsView: View {
    let cast: [Cast]
    let crew: [Crew]
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Cast & Crew")
                    .textCase(.uppercase)
                    .foregroundColor(.secondary)
                    .padding([.horizontal, .top])
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if !cast.isEmpty {
                        ForEach(cast.prefix(10)) { item in
                            NavigationLink(destination: CastView( title: item.name, id: item.id)) {
                                CreditProfileImage(name: item.name , characterOrJob: item.role, imageUrl: item.image)
                            }
                            .padding(.leading, item.id == self.cast.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == self.cast.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                    if !crew.isEmpty {
//                        ForEach(crew.prefix(5)) { item in
//                            CreditProfileImage(name: item.name, characterOrJob: item.role, imageUrl: item.image)
//                                .padding(.trailing, item.id == self.crew.last!.id ? 16 : 0)
//                                .padding([.top, .bottom])
//                        }
                        ForEach(crew) { content in
                            switch content.role {
                            case "Director":
                                CreditProfileImage(name: content.name, characterOrJob: content.role, imageUrl: content.image)
                            case "Producer":
                                CreditProfileImage(name: content.name, characterOrJob: content.role, imageUrl: content.image)
                            case "Screenplay":
                                CreditProfileImage(name: content.name, characterOrJob: content.role, imageUrl: content.image)
                            default:
                                EmptyView()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct HorizontalCreditsView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalCreditsView(cast: Credits.previewCredits.cast, crew: Credits.previewCredits.crew)
    }
}
