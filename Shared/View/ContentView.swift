//
//  ContentView.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        iOSView()
        #else
        iPadView()
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
