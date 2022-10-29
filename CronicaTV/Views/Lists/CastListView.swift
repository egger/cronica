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
                ListTitleView(title: "Cast & Crew", subtitle: "", image: "person.3")
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(credits) { item in
                            VStack {
                                PersonCircleView(person: item)
                                Text(item.name)
                                    .font(.caption)
                                    .lineLimit(1)
                                if let role = item.personRole {
                                    Text(role)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding([.leading, .trailing], 4)
                            .padding(.leading, item.id == credits.first!.id ? 16 : 0)
                            .padding(.trailing, item.id == credits.last!.id ? 16 : 0)
                            .padding([.top, .bottom])
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct CastListView_Previews: PreviewProvider {
    static var previews: some View {
        CastListView(credits: [Person.previewCast])
    }
}
