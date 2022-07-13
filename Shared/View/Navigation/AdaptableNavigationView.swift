//
//  AdaptableNavigationView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/06/22.
//

import SwiftUI

/// A view that handles multi platform behaviors.
/// On iOS, this view will put the content inside a NavigationStack.
/// On iPadOS/macOS, this view will just present the content without any alterations,
/// just to conform to the SideBar.
struct AdaptableNavigationView<Content: View>: View {
    var content: () -> Content
    @ViewBuilder
    var body: some View {
        if !UIDevice.isIPad {
            NavigationStack {
                content()
            }
        } else {
            content()
        }
    }
}

struct AdaptableNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AdaptableNavigationView {
            Text("This is a preview.")
        }
    }
}
