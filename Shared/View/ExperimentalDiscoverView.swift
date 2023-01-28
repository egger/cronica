//
//  ExperimentalDiscoverView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 26/01/23.
//

import SwiftUI

struct ExperimentalDiscoverView: View {
    @State private var showFilters = false
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("Discover")
            .toolbar {
                Button {
                    showFilters.toggle()
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
            .sheet(isPresented: $showFilters) {
                VStack {
                    Button("Apply") { }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(width: 400)
                }
            }
        }
    }
}

struct ExperimentalDiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentalDiscoverView()
    }
}
