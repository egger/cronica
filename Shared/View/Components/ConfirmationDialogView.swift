//
//  ConfirmationDialogView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/06/22.
//

import SwiftUI

/// A dialog that displays a message inside a container of the top of the view.
///
/// The user can tap it to dismiss it faster.
struct ConfirmationDialogView: View {
    @Binding var showConfirmation: Bool
    var message: String
    var image: String?
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            Spacer()
            HStack {
                if let image {
                    Label(NSLocalizedString(message, comment: ""), systemImage: image)
                        .padding()
                } else {
                    Text(NSLocalizedString(message, comment: ""))
                        .padding()
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .fontWeight(.regular)
                }
            }
            .background { Rectangle().fill(.thickMaterial) }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding()
            .shadow(radius: 5)
            .opacity(showConfirmation ? 1 : 0)
            .animation(.easeInOut, value: showConfirmation)
            .onTapGesture { withAnimation { showConfirmation = false } }
        }
    }
}

struct ConfirmationDialogView_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationDialogView(showConfirmation: .constant(true), message: "This is a preview")
    }
}
