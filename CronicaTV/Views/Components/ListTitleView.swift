//
//  ListTitleView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 29/10/22.
//

import SwiftUI

struct ListTitleView: View {
    let title: String
    let subtitle: String
    let image: String
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Text(NSLocalizedString(title, comment: ""))
                        .font(.callout)
                        .padding([.top, .horizontal])
                    Spacer()
                }
                HStack {
                    Text(NSLocalizedString(subtitle, comment: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            Spacer()
            Image(systemName: image)
                .foregroundColor(.secondary)
                .padding()
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ListTitleView_Previews: PreviewProvider {
    static var previews: some View {
        ListTitleView(title: "New Content", subtitle: "Preview", image: "film")
    }
}
