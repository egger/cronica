//
//  WatchlistTitle.swift
//  Story
//
//  Created by Alexandre Madeira on 16/02/23.
//

import SwiftUI

struct WatchlistTitle: View {
    @Binding var navigationTitle: String
    @Binding var showListSelection: Bool
    @State private var isRotating = 0.0
    var body: some View {
        HStack {
            Text(navigationTitle)
                .fontWeight(Font.Weight.semibold)
                .lineLimit(1)
                .foregroundColor(showListSelection ? .secondary : nil)
            Image(systemName: "chevron.down.circle.fill")
                .fontWeight(.bold)
                .font(.caption)
                .foregroundColor(.secondary)
                .rotationEffect(.degrees(isRotating))
                .task(id: showListSelection) {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        if showListSelection {
                            isRotating = -180.0
                        } else {
                            isRotating = 0.0
                        }
                    }
                }
                .foregroundColor(showListSelection ? .secondary : nil)
        }
        .onTapGesture {
            showListSelection.toggle()
        }
        .accessibilityLabel("\(navigationTitle), tap to open list options.")
    }
}
