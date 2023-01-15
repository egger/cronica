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
            Divider().padding(.horizontal)
            Section {
                Text(about)
                    .lineLimit(showOverview ? nil : 4)
            } header: {
                HStack {
                    Label("About", systemImage: "film")
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            .onTapGesture {
                withAnimation { showOverview.toggle() }
            }
            Divider().padding(.horizontal)
        }
    }
}


struct AboutSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSectionView(about: ItemContent.previewContent.itemOverview)
    }
}
