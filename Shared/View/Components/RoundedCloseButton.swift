//
//  RoundedCloseButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 11/04/24.
//

import SwiftUI

struct RoundedCloseButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .imageScale(.medium)
                .accessibilityLabel("Close")
                .fontDesign(.rounded)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
        }
        .buttonStyle(.borderedProminent)
        .contentShape(Circle())
        .clipShape(Circle())
        .buttonBorderShape(.circle)
        .shadow(radius: 2.5)
    }
}
