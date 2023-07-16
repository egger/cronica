//
//  ConfirmationPopupModifier.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/06/22.
//

import SwiftUI

/// A dialog that displays a message inside a container of the top of the view.
///
/// The user can tap it to dismiss it faster.
struct ConfirmationPopupModifier: ViewModifier {
    @Binding var isShowing: Bool
    var item: ActionPopupItems?
    func body(content: Content) -> some View {
        content
            .overlay {
                if isShowing {
                    if let item {
                        VStack {
                            Spacer()
                            HStack {
                                Label(item.localizedString, systemImage: item.toSfSymbol)
                                    .padding()
                            }
#if !os(watchOS)
                            .background { Rectangle().fill(.thinMaterial) }
#endif
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(radius: 2.5)
                            .padding()
                            .opacity(isShowing ? 1 : 0)
                            .animation(.easeInOut, value: isShowing)
                            .onTapGesture { withAnimation { isShowing = false } }
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                    }
                }
            }
    }
}

enum ActionPopupItems: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case addedWatchlist, removedWatchlist, markedWatched, removedWatched, markedFavorite, removedFavorite,
         markedArchive, removedArchive, markedPin, removedPin
    
    var localizedString: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    var toSfSymbol: String {
        switch self {
        case .addedWatchlist:
            return "plus.circle.fill"
        case .removedWatchlist:
            return "minus.circle.fill"
        case .markedWatched:
            return "rectangle.badge.checkmark.fill"
        case .removedWatched:
            return "rectangle.badge.checkmark"
        case .markedFavorite:
            return "heart.circle.fill"
        case .removedFavorite:
            return "heart.slash.fill"
        case .markedArchive:
            return "archivebox.fill"
        case .removedArchive:
            return "archivebox"
        case .markedPin:
            return "pin.fill"
        case .removedPin:
            return "pin.slash.fill"
        }
    }
}
