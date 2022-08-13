//
//  AboutSectionView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct AboutSectionView: View {
     let about: String?
     var body: some View {
         if let about {
             Divider().padding(.horizontal)
             Section {
                 Text(about)
             } header: {
                 HStack {
                     Label("About", systemImage: "film")
                         .foregroundColor(.secondary)
                     Spacer()
                 }
             }
             .padding()
             Divider().padding(.horizontal)
         }
     }
 }

 struct AboutSectionView_Previews: PreviewProvider {
     static var previews: some View {
         AboutSectionView(about: "Preview AboutSectionView on Apple Watch!")
     }
 }
