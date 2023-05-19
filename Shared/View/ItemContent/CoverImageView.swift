//
//  CoverImageView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 06/06/22.
//
import SwiftUI
import SDWebImageSwiftUI

struct CoverImageView: View {
    @StateObject private var store = SettingsStore.shared
    @EnvironmentObject var viewModel: ItemContentViewModel
    @State private var animateGesture = false
    let title: String
    @State private var animationImage = ""
    var body: some View {
        VStack {
            HeroImage(url: viewModel.content?.cardImageLarge,
                      title: title)
            .overlay {
                ZStack {
                    Rectangle().fill(.ultraThinMaterial)
                    Image(systemName: animationImage)
                        .symbolRenderingMode(.multicolor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120, alignment: .center)
                        .scaleEffect(animateGesture ? 1.1 : 1)
                }
                .opacity(animateGesture ? 1 : 0)
            }
            .frame(width: DrawingConstants.imageWidth, height: DrawingConstants.imageHeight)
            .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.imageRadius, style: .continuous))
            .shadow(radius: DrawingConstants.shadowRadius)
            .padding([.top, .bottom])
            .accessibilityElement(children: .combine)
            .accessibility(hidden: true)
            .onTapGesture(count: 2) {
                animate(for: store.gesture)
                viewModel.update(store.gesture)
            }
            if let info = viewModel.content?.itemInfo {
                Text(info)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func animate(for type: UpdateItemProperties) {
        switch type {
        case .watched: animationImage = viewModel.isWatched ? "minus.circle.fill" : "checkmark.circle"
        case .favorite: animationImage = viewModel.isFavorite ? "heart.slash.fill" : "heart.fill"
        case .pin: animationImage = viewModel.isPin ? "pin.slash" : "pin"
        case .archive: animationImage = viewModel.isArchive ? "archivebox.fill" : "archivebox"
        }
        withAnimation { animateGesture.toggle() }
        HapticManager.shared.successHaptic()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation { animateGesture = false }
        }
    }
}

private struct DrawingConstants {
    static let shadowRadius: CGFloat = 5
    static let imageWidth: CGFloat = 360
    static let imageHeight: CGFloat = 210
    static let imageRadius: CGFloat = 8
}

