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
#if os(iOS) || os(tvOS)
        TabBarView()
//#if os(iOS)
//            .appTint()
//#endif
#elseif os(macOS)
        SideBarView()
#endif   
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
