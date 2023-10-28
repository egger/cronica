//
//  CenterVerticalView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 30/11/22.
//

import SwiftUI

struct CenterVerticalView<Content: View>: View {
    var content: () -> Content
    @ViewBuilder
    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

#Preview {
    CenterVerticalView {
        ProgressView {
            Label("This is a preview", systemImage: "smiley")
        }
    }
}
