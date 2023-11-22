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
                if isShowing {
                    if let item {
                        VStack {
#if os(tvOS)
                            HStack {
                                Spacer()
                                HStack {
                                    Label(item.localizedString, systemImage: item.toSfSymbol)
                                        .fontWeight(.semibold)
                                        .padding()
                                }
                                .background { Rectangle().fill(.ultraThickMaterial) }
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 10)
                                .padding()
                                .opacity(isShowing ? 1 : 0)
                                .animation(.linear, value: isShowing)
                            }
#endif
                            Spacer()
#if !os(tvOS)
                            HStack {
                                if #available(iOS 17, *), #available(watchOS 10, *), #available(macOS 14, *), #available(tvOS 17, *) {
                                    Label(item.localizedString, systemImage: item.toSfSymbol)
                                        .symbolEffect(.bounce, value: isShowing)
                                        .padding()
                                } else {
                                    Label(item.localizedString, systemImage: item.toSfSymbol)
                                        .padding()
                                }
                            }
#if !os(watchOS)
                            .background { Rectangle().fill(.regularMaterial) }
#endif
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(radius: 2)
                            .padding()
                            .opacity(isShowing ? 1 : 0)
                            .animation(.linear, value: isShowing)
                            .onTapGesture { withAnimation { isShowing = false } }
#endif
                        }
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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
         markedArchive, removedArchive, markedPin, removedPin, markedEpisodeWatched, removedEpisodeWatched,
         feedbackSent
    
    var localizedString: String { return NSLocalizedString(rawValue, comment: "") }
    
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
