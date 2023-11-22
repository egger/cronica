//
//  EmptyListView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 21/04/23.
//

import SwiftUI

struct EmptyListView: View {
    var body: some View {
        if #available(watchOS 10, *) {
            ContentUnavailableView("Your list is empty.", systemImage: "rectangle.on.rectangle")
                .padding()
        } else {
            Text("Your list is empty.")
        }
    }
}

#Preview {
    EmptyListView()
}
