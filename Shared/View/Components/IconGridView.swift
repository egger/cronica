//
//  IconGridView.swift
//  Cronica
//
//  Created by Alexandre Madeira on 08/08/23.
//

import SwiftUI

struct IconGridView: View {
    @Binding var isFavorite: Bool
    @Binding var isPin: Bool
    
    var body: some View {
        if isSingleIconVisible {
            // Display the single icon alone, bigger.
            getSingleIcon()
                .imageScale(.medium)
                .symbolRenderingMode(.multicolor)
                .padding()
        } else if hasNoIcon {
            EmptyView()
        } else {
            VStack {
                iconImage(systemName: "heart.fill", isVisible: isFavorite)
                    .padding(.bottom, 1)
                iconImage(systemName: "pin.fill", isVisible: isPin)
            }
        }
    }
    
    @ViewBuilder
    private func iconImage(systemName: String, isVisible: Bool) -> some View {
        if isVisible {
            Image(systemName: systemName)
                .imageScale(.small)
                .symbolRenderingMode(.multicolor)
                .padding(.trailing)
        } else {
            Color.clear  // Placeholder to maintain layout even if icon is hidden
        }
    }
    
    private var isSingleIconVisible: Bool {
        let visibleIconsCount = [isFavorite, isPin].filter { $0 }.count
        return visibleIconsCount == 1
    }
    
    private var hasNoIcon: Bool {
        let visibleIconsCount = [isFavorite, isPin].filter { $0 }.count
        return visibleIconsCount == 0
    }
    
    private func getSingleIcon() -> Image {
        if isFavorite {
            return Image(systemName: "heart.fill")
        } else {
            return Image(systemName: "pin.fill")
        }
    }
}


#Preview {
    IconGridView(isFavorite: .constant(true), isPin: .constant(true))
}
