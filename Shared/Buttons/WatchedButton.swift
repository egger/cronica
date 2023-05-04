//
//  WatchedButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct WatchedButton: View {
    let id: String
    @Binding var isWatched: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updateWatched) {
            Label(isWatched ? "Remove from Watched" : "Mark as Watched",
                  systemImage: isWatched ? "minus.circle" : "checkmark.circle")
        }
    }
    
    private func updateWatched() {
        do {
            guard let item = try persistence.fetch(for: id) else { return }
            persistence.updateWatched(for: item)
            withAnimation { isWatched.toggle() }
            HapticManager.shared.successHaptic()
            if item.itemMedia == .tvShow { updateSeasons() }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func updateSeasons() {
        
    }
}

struct WatchedButton_Previews: PreviewProvider {
    static var previews: some View {
        WatchedButton(id: ItemContent.previewContent.itemNotificationID,
                      isWatched: .constant(true))
    }
}
