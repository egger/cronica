//
//  FavoriteButton.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 04/05/23.
//

import SwiftUI

struct FavoriteButton: View {
    let id: String
    @Binding var isFavorite: Bool
    @Binding var popupType: ActionPopupItems?
    @Binding var showPopup: Bool
    private let persistence = PersistenceController.shared
    var body: some View {
        Button(action: updateFavorite) {
            Label(isFavorite ? "Remove from Favorites" : "Mark as Favorite",
                  systemImage: isFavorite ? "heart.slash.fill" : "heart")
        }
    }
    
    private func updateFavorite() {
        guard let item = persistence.fetch(for: id) else { return }
        persistence.updateFavorite(for: item)
        withAnimation {
            isFavorite.toggle()
            popupType = isFavorite ? .markedFavorite : .removedFavorite
            showPopup = true
        }
        HapticManager.shared.successHaptic()
    }
}

#Preview {
    FavoriteButton(id: ItemContent.example.itemContentID,
                   isFavorite: .constant(true),
                   popupType: .constant(nil),
                   showPopup: .constant(false))
}
