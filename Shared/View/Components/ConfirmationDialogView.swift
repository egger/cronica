//
//  ConfirmationDialogView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/06/22.
//

import SwiftUI

/// A popup view the displays a confirmation if a given
/// item is saved on Watchlist.
struct ConfirmationDialogView: View {
    @Binding var showConfirmation: Bool
    var message: String = "Added to watchlist"
    var image: String = "checkmark.circle"
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Label(NSLocalizedString(message, comment: ""), systemImage: image)
                    .padding()
            }
            .background {
                Rectangle().fill(.ultraThickMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding()
            .shadow(radius: 12)
            .opacity(showConfirmation ? 1 : 0)
            .scaleEffect(showConfirmation ? 1.1 : 1)
            .animation(.easeInOut, value: showConfirmation)
            .onTapGesture {
                withAnimation {
                    showConfirmation = false
                }
            }
        }
    }
}

struct ConfirmationDialogView_Previews: PreviewProvider {
    @State private static var showConfirmation = true
    static var previews: some View {
        ConfirmationDialogView(showConfirmation: $showConfirmation)
    }
}
