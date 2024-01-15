//
//  ConfirmationPopupModifier.swift
//  Cronica (iOS)
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
                if isShowing, let item {
                    HStack {
                        Label(item.localizedString, systemImage: item.toSfSymbol)
                            .font(.body)
                            .fontDesign(.rounded)
                            .padding()
                            
                    }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.snappy) {
                                isShowing = false
                            }
                        }
                    }
#if !os(watchOS)
                    .background { Rectangle().fill(.thickMaterial) }
#endif
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(radius: 1)
                    .padding(.bottom)
                    .animation(.snappy, value: isShowing)
                    .onTapGesture { withAnimation { isShowing = false } }
                    .transition(.move(edge: .bottom))
                    .frame (maxHeight: .infinity, alignment: .bottom)
                }
            }
    }
}

enum ActionPopupItems: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    case addedWatchlist, removedWatchlist, markedWatched, removedWatched, markedFavorite, removedFavorite,
         markedArchive, removedArchive, markedPin, removedPin, markedEpisodeWatched, removedEpisodeWatched,
         feedbackSent
    
    var localizedString: String {
        switch self {
        case .addedWatchlist:
            return NSLocalizedString("Added", comment: "")
        case .removedWatchlist:
            return NSLocalizedString("Removed", comment: "")
        case .markedWatched:
            return NSLocalizedString("Watched", comment: "")
        case .removedWatched:
            return NSLocalizedString("Unwatched", comment: "")
        case .markedFavorite:
            return NSLocalizedString("Favorited", comment: "")
        case .removedFavorite:
            return NSLocalizedString("Unfavorited", comment: "")
        case .markedArchive:
            return NSLocalizedString("Archived", comment: "")
        case .removedArchive:
            return NSLocalizedString("Unarchived", comment: "")
        case .markedPin:
            return NSLocalizedString("Pinned", comment: "")
        case .removedPin:
            return NSLocalizedString("Unpinned", comment: "")
        case .markedEpisodeWatched:
            return NSLocalizedString("Watched", comment: "")
        case .removedEpisodeWatched:
            return NSLocalizedString("Unwatched", comment: "")
        case .feedbackSent:
            return NSLocalizedString("Feedback sent. Thank you.", comment: "")
        }
    }
    
    var toSfSymbol: String {
        switch self {
        case .addedWatchlist: return "plus.circle.fill"
        case .removedWatchlist: return "minus.circle.fill"
        case .markedWatched: return "rectangle.badge.checkmark.fill"
        case .removedWatched: return "rectangle.badge.checkmark"
        case .markedFavorite: return "heart.fill"
        case .removedFavorite: return "heart.slash.fill"
        case .markedArchive: return "archivebox.fill"
        case .removedArchive: return "archivebox"
        case .markedPin: return "pin.fill"
        case .removedPin: return "pin.slash.fill"
        case .markedEpisodeWatched: return "rectangle.badge.checkmark.fill"
        case .removedEpisodeWatched: return "rectangle.badge.checkmark"
        case .feedbackSent: return "envelope.fill"
        }
    }
}
