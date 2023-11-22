//
//  TranslucentBackground.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 19/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

@available(watchOS 10.0, *)
struct TranslucentBackground: View {
    var image: URL?
    @AppStorage("disableTranslucentBackground") private var disableTranslucent = false
    var body: some View {
        if !disableTranslucent && image != nil {
            ZStack {
                WebImage(url: image)
                    .resizable()
                    .placeholder {
                        Rectangle()
                            .fill(.background)
                            .ignoresSafeArea()
                            .padding(.zero)
                    }
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .padding(.zero)
                    .transition(.opacity)
#if os(watchOS)
                Rectangle()
                    .fill(.thickMaterial)
                    .ignoresSafeArea()
                    .padding(.zero)
#elseif os(macOS) || os(iOS)
                Rectangle()
                    .fill(.ultraThickMaterial)
                    .ignoresSafeArea()
                    .padding(.zero)
#else
                Rectangle()
                    .fill(.thickMaterial)
                    .ignoresSafeArea()
                    .padding(.zero)
#endif
            }
        }
    }
}
