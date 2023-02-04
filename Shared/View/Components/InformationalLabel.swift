//
//  InformationalLabel.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct InformationalLabel: View {
    let title: String
    var subtitle: String?
    var image: String?
    var body: some View {
        if let image {
            HStack {
                VStack {
                    Image(systemName: image)
                }
                VStack(alignment: .leading) {
                    Text(NSLocalizedString(title, comment: ""))
                    if let subtitle {
                        Text(NSLocalizedString(subtitle, comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } else {
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
}

struct InformationalToggle_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Button {
                
            } label: {
                InformationalLabel(title: "Preview", subtitle: "SwiftUI Preview")
            }
            Button {
                
            } label: {
                InformationalLabel(title: "Action Title", subtitle: "Action Subtitle", image: "flag")
            }
            
        }
    }
}
