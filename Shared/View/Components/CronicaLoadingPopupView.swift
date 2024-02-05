//
//  CronicaLoadingPopupView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 23/01/24.
//

import SwiftUI

struct CronicaLoadingPopupView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack {
                ProgressView("Loading")
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .tint(.secondary)
                    .padding()
            }
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.black.opacity(0.2), lineWidth: 0.3)
            )
            .frame(width: 180, height: 150, alignment: .center)
            .unredacted()
            Spacer()
        }
    }
}
