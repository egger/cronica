//
//  CenterHorizontalView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 29/10/22.
//

import SwiftUI

struct CenterHorizontalView<Content: View>: View {
    var content: () -> Content
    @ViewBuilder
    var body: some View {
        HStack(alignment: .center) {
            content()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CenterHorizontalView {
        Label("Preview", systemImage: "square.stack")
    }
}
