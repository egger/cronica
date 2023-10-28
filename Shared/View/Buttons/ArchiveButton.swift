//
//  ArchiveButton.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct ArchiveButton: View {
    let id: String
    @Binding var isArchive: Bool
    @Binding var popupType: ActionPopupItems?
    @Binding var showPopup: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updateArchive) {
            Label(isArchive ? "Remove from Archive" : "Archive Item",
                  systemImage: isArchive ? "archivebox.fill" : "archivebox")
        }
    }
    
    private func updateArchive() {
        guard let item = persistence.fetch(for: id) else { return }
        persistence.updateArchive(for: item)
        withAnimation { isArchive.toggle() }
        if isArchive {
            NotificationManager.shared.removeNotification(identifier: id)
        }
        HapticManager.shared.successHaptic()
#if !os(watchOS)
        popupType = isArchive ? .markedArchive : .removedArchive
        withAnimation { showPopup = true }
#endif
    }
}

#Preview {
    ArchiveButton(id: ItemContent.example.itemContentID,
                  isArchive: .constant(false),
                  popupType: .constant(nil),
                  showPopup: .constant(true))
}
