//
//  CompanionTextView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 13/08/22.
//

import SwiftUI

struct CompanionTextView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("For more details, open the companion app.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct CompanionTextView_Previews: PreviewProvider {
    static var previews: some View {
        CompanionTextView()
    }
}
