//
//  TrendingView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 16/06/22.
//

import SwiftUI

struct TrendingView: View {
    @State private var showConfirmation: Bool = false
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    
                }
            }
            .navigationTitle("Trending")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    Menu(content: {
                        
                    }, label: {
                        Label("Type", systemImage: "tv")
                    })
                })
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
}

struct TrendingView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingView()
    }
}
