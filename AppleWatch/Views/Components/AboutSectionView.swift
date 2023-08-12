//
//  AboutSectionView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 29/09/22.
//

import SwiftUI

struct AboutSectionView: View {
    let about: String?
	@State private var showAbout = false
    var body: some View {
        if let about {
            if !about.isEmpty {
                Section {
                    VStack(alignment: .leading) {
                        Text(about)
							.lineLimit(4)
                    }
					.onTapGesture {
						showAbout = true
					}
					.sheet(isPresented: $showAbout) {
						ScrollView {
							Text(about)
								.padding()
						}
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
