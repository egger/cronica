//
//  TranslucentBackground.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 19/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TranslucentBackground: View {
    var image: URL?
    @AppStorage("newBackgroundStyle") private var newBackgroundStyle = false
    var body: some View {
        if newBackgroundStyle && image != nil {
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
                Rectangle()
#if os(iOS)
                    .fill(.regularMaterial)
#else
                    .fill(.ultraThickMaterial)
#endif
                    .ignoresSafeArea()
                    .padding(.zero)
            }
        }
    }
}

struct TranslucentBackground_Previews: PreviewProvider {
    static var previews: some View {
        TranslucentBackground()
    }
}
