//
//  AdaptableNavigationView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 21/06/22.
//

import SwiftUI

/// A view that handles multi platform behaviors.
/// 
/// On iOS, this view will put the content inside a NavigationStack.
/// On iPadOS/macOS, this view will just present the content without any alterations,
/// just to conform to the SideBar.
struct AdaptableNavigationView<Content: View>: View {
    let content: () -> Content
    @State private var path = NavigationPath()
    @EnvironmentObject var coordinator: Coordinator
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    var body: some View {
        if UIDevice.isIPhone {
            NavigationStack(path: $path) {
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
