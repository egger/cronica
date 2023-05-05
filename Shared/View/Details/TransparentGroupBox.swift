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
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            configuration.content
                .foregroundColor(.white)
        }
        .padding()
        .background {
            ZStack {
                Rectangle().fill(.black.opacity(0.2))
                Rectangle().fill(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
#endif
