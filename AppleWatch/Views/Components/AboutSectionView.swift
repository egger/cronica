//
//  AboutSectionView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 29/09/22.
//

import SwiftUI

struct AboutSectionView: View {
    let about: String?
    var body: some View {
        if let about {
            if !about.isEmpty {
                Section {
                    VStack(alignment: .leading) {
                        Text(about)
                    }
                } header: {
                    HStack {
                        Text("About")
                        Spacer()
                    }
                }
                .padding()
            }
        }
    }
}


struct AboutSectionView_Previews: PreviewProvider {
    static var previews: some View {
        AboutSectionView(about: ItemContent.example.itemOverview)
    }
}
