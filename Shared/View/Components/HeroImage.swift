//
//  HeroImage.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct HeroImage: View {
	let url: URL?
	let title: String
	var type: MediaType = .movie
	var body: some View {
		WebImage(url: url, options: .highPriority)
			.resizable()
			.placeholder {
				ZStack {
					Rectangle().fill(.gray.gradient)
					Image(systemName: "popcorn.fill")
						.font(.title)
						.fontWidth(.expanded)
						.foregroundColor(.white.opacity(0.8))
						.unredacted()
						.padding()
				}
				.transition(.opacity)
			}
			.aspectRatio(contentMode: .fill)
			.transition(.opacity)
#if os(watchOS)
			.frame(height: 90)
			.clipShape(
				RoundedRectangle(cornerRadius: 8,
								 style: .continuous)
			)
			.padding()
#endif
	}
}

#Preview {
    HeroImage(url: ItemContent.example.cardImageLarge,
              title: ItemContent.example.itemTitle)
}
