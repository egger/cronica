//
//  ContentView.swift
//  Shared
//
//  Created by Alexandre Madeira on 14/01/22.
//

import SwiftUI

struct ContentView: View {
    @State private var isPad: Bool = UIDevice.isIPad
    var body: some View {
        //SideBarView()
        TabBarView()
//        if isPad {
//            SideBarView()
//        } else {
//            TabBarView()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
