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
        HStack {
            Spacer()
            content()
            Spacer()
        }
    }
}

struct CenterHorizontalView_Previews: PreviewProvider {
    static var previews: some View {
        CenterHorizontalView {
            Label("Preview", systemImage: "square.stack")
        }
    }
}
