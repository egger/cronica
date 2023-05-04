//
//  PinButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct PinButton: View {
    let id: String
    @Binding var isPin: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updatePin) {
            Label(isPin ? "Unpin Item" : "Pin Item",
                  systemImage: isPin ? "pin.slash" : "pin")
        }
    }
    
    private func updatePin() {
        do {
            guard let item = try persistence.fetch(for: id) else { return }
            persistence.updatePin(for: item)
            withAnimation { isPin.toggle() }
            HapticManager.shared.successHaptic()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct PinButton_Previews: PreviewProvider {
    static var previews: some View {
        PinButton(id: ItemContent.previewContent.itemNotificationID,
                  isPin: .constant(false))
    }
}
