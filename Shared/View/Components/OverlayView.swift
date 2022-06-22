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
struct RetryView: View {
    let message: String
    let retryAction: () -> Void
    var body: some View {
        VStack {
            Text(message)
                .font(.callout)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
            Button("Try Again") {
                retryAction()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.purple)
            .padding([.bottom, .horizontal])
        }
        .background(.primary)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding()
    }
}
