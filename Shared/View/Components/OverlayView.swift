//
//  OverlayView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

protocol EmptyData {
    var isEmpty: Bool { get }
}
struct OverlayView<T: EmptyData>: View {
    let phase: DataFetchPhase<T>
    let retry: () -> Void
    let title: String
    var body: some View {
        VStack {
            switch phase {
            case .failure(let error):
                RetryView(text: error.localizedDescription, retryAction: retry)
            default:
                EmptyView()
            }
        }
    }
}
struct RetryView: View {
    let text: String
    let retryAction: () -> Void
    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.callout)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding([.top, .horizontal])
            Button(action: retryAction) {
                Label("Try Again", systemImage: "repeat.circle")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.purple)
            .padding([.bottom, .horizontal])
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding()
    }
}
