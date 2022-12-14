//
//  InformationalToggle.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct InformationalToggle: View {
    let title: String
    var subtitle: String?
    var body: some View {
        VStack(alignment: .leading) {
            Text(NSLocalizedString(title, comment: ""))
            if let subtitle {
                Text(NSLocalizedString(subtitle, comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct InformationalToggle_Previews: PreviewProvider {
    static var previews: some View {
        InformationalToggle(title: "Preview", subtitle: "SwiftUI Preview")
    }
}
