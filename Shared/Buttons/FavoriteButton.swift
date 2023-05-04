//
//  FavoriteButton.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct FavoriteButton: View {
    let id: String
    @Binding var isFavorite: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updateFavorite) {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.circle.fill" : "heart.circle")
        }
    }
    
    private func updateFavorite() {
        do {
            guard let item = try persistence.fetch(for: id) else { return }
            persistence.updateFavorite(for: item)
            withAnimation { isFavorite.toggle() }
            HapticManager.shared.successHaptic()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(id: ItemContent.previewContent.itemNotificationID,
                       isFavorite: .constant(true))
    }
}
