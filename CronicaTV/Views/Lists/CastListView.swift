//
//  CastListView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct CastListView: View {
    let credits: [Person]
    var body: some View {
        if !credits.isEmpty {
            VStack(alignment: .leading) {
                HStack {
                    HStack {
                        Text(NSLocalizedString("Cast & Crew", comment: ""))
                            .font(.callout)
                            .padding([.top, .horizontal])
                        Spacer()
                    }
                    Spacer()
                    Image(systemName: "person.3")
                        .foregroundColor(.secondary)
                        .padding()
                        .accessibilityHidden(true)
                }
                .accessibilityElement(children: .combine)
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(credits) { item in
                            PersonCircleView(person: item)
                                .padding([.leading, .trailing], 4)
                                .padding(.leading, item.id == credits.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == credits.last!.id ? 16 : 0)
                                .padding([.top, .bottom])
                        }
                    }
                }
            }
        }
    }
}

struct CastListView_Previews: PreviewProvider {
    static var previews: some View {
        CastListView(credits: [Person.previewCast])
    }
}
