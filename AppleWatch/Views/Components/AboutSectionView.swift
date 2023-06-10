//
//  AboutSectionView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 29/09/22.
//

import SwiftUI

struct AboutSectionView: View {
    let about: String?
    @State private var showOverview = false
    var body: some View {
        if let about {
            if !about.isEmpty {
                Section {
                    VStack(alignment: .leading) {
                        Text(about)
                            .lineLimit(4)
                        Text("See More")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 4)
                    }
                } header: {
                    HStack {
                        Text("About")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .onTapGesture { withAnimation { showOverview.toggle() } }
                .sheet(isPresented: $showOverview) {
                    ScrollView {
                        Text(about)
                            .padding()
                    }
                }
            }
        }
    }
}


struct AboutSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSectionView(about: ItemContent.example.itemOverview)
    }
}
