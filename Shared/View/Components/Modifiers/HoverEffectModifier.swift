//
//  HoverEffectModifier.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 03/11/22.
//

import SwiftUI

struct HoverEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
#if os(iOS)
        return content
            .hoverEffect(.automatic)
#else
        return content
            .buttonStyle(.plain)
#endif
    }
}

extension View {
    func applyHoverEffect() -> some View {
        modifier(HoverEffectModifier())
    }
}
