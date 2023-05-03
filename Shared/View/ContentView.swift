//
//  ContentView.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct ContentView: View {
#if os(iOS)
    @State private var isPad = UIDevice.isIPad
#endif
    var body: some View {
#if os(iOS)
        if isPad {
            SideBarView()
                .appTint()
        } else {
            TabBarView()
                .appTint()
        }
#elseif os(macOS)
        SideBar()
#elseif os(tvOS)
        TabBarView()
#endif   
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
