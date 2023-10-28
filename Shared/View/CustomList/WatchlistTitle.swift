//
//  WatchlistTitle.swift
//  Cronica
//
//  Created by Alexandre Madeira on 16/02/23.
//

import SwiftUI

struct WatchlistTitle: View {
    @Binding var navigationTitle: String
    @Binding var showListSelection: Bool
    @State private var isRotating = 0.0
    var body: some View {
        Button {
            showListSelection = true
        } label: {
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
                        withAnimation(.easeInOut) {
                            if showListSelection {
                                isRotating = -180.0
                            } else {
                                isRotating = 0.0
                            }
                        }
                    }
                    .foregroundColor(showListSelection ? .secondary : nil)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(navigationTitle), tap to open list options.")
    }
}
