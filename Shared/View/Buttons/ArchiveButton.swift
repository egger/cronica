//
//  ArchiveButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct ArchiveButton: View {
    let id: String
    @Binding var isArchive: Bool
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
    }
}

struct ArchiveButton_Previews: PreviewProvider {
    static var previews: some View {
        ArchiveButton(id: ItemContent.example.itemContentID, isArchive: .constant(false))
    }
}
