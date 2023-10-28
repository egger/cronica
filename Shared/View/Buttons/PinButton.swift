//
//  PinButton.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct PinButton: View {
    let id: String
    @Binding var isPin: Bool
    @Binding var popupType: ActionPopupItems?
    @Binding var showPopup: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updatePin) {
            Label(isPin ? "Unpin Item" : "Pin Item", systemImage: isPin ? "pin.slash" : "pin")
        }
    }
    
    private func updatePin() {
        guard let item = persistence.fetch(for: id) else { return }
        persistence.updatePin(for: item)
        withAnimation {
            isPin.toggle()
            popupType = isPin ? .markedPin : .removedPin
            showPopup = true
        }
        HapticManager.shared.successHaptic()
    }
}

#Preview {
    PinButton(id: ItemContent.example.itemContentID,
              isPin: .constant(false),
              popupType: .constant(nil),
              showPopup: .constant(false))
}
