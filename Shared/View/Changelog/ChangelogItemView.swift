//
//  ChangelogItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct ChangelogItemView: View {
    let title: String
    let description: String
    let image: String
    let color: Color
    @Binding var isDisplayingTipJar: Bool
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
                .foregroundColor(isDisplayingTipJar ? .secondary : color)
            VStack(alignment: .leading) {
                Text(LocalizedStringKey(title))
                    .font(.title3)
                    .fontWeight(.semibold)
                Text(LocalizedStringKey(description))
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 12)
            Spacer()
        }
        .padding(.horizontal)
    }
}

struct ChangelogItemView_Previews: PreviewProvider {
    static var previews: some View {
        ChangelogItemView(title: "Preview",
                          description: "SwiftUI Preview",
                          image: "checkmark", color: .blue, isDisplayingTipJar: .constant(true))
    }
}
