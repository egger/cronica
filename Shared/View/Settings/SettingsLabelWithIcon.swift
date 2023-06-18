//
//  SettingsLabelWithIcon.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 03/04/23.
//

import SwiftUI

/// An horizontal row item customized to look like the Settings app's row items.
struct SettingsLabelWithIcon: View {
    let title: String
    let icon: String
    let color: Color
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30, alignment: .center)
            .padding(.trailing, 8)
            .accessibilityHidden(true)
            Text(LocalizedStringKey(title))
        }
        .padding(.vertical, 2)
    }
}

struct SettingsLabelWithIcon_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SettingsLabelWithIcon(title: "Swift", icon: "hammer", color: .purple)
            SettingsLabelWithIcon(title: "Preview", icon: "hammer", color: .orange)
        }
    }
}
