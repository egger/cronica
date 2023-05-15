//
//  CustomListButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct CustomListButton: View {
    let id: String
    @Binding var showCustomListView: Bool
    var body: some View {
        Button {
            showCustomListView.toggle()
        } label: {
            Label("addToList", systemImage: "rectangle.on.rectangle.angled")
        }
    }
}

struct CustomListButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomListButton(id: ItemContent.example.itemContentID, showCustomListView: .constant(true))
    }
}
