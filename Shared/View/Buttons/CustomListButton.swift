//
//  CustomListButton.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct CustomListButton: View {
    let id: String
    @Binding var showCustomListView: Bool
    var body: some View {
        Button("Add To List", systemImage: "rectangle.on.rectangle.angled") {
            showCustomListView.toggle()
        }
    }
}

#Preview {
    CustomListButton(id: ItemContent.example.itemContentID, showCustomListView: .constant(true))
}
