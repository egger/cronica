//
//  TransparentGroupBox.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/05/23.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct TransparentGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                configuration.label
                    .fontDesign(.rounded)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            configuration.content
                .foregroundColor(.primary)
        }
        .padding()
        .background {
            ZStack {
                Rectangle().fill(.background)
            }
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(radius: 1)
        }
    }
}
#endif
