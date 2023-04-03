//
//  ContentView.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct ContentView: View {
#if os(iOS)
    @State private var isPad: Bool = UIDevice.isIPad
#endif
    var body: some View {
#if os(iOS)
        if isPad {
            SideBarView()
        } else {
            TabBarView()
        }
#elseif os(macOS)
        MacSideBarView()
#endif   
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
