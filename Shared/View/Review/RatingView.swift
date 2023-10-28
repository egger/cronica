//
//  RatingView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 25/04/23.
//

import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    var label = String()
    var maximumRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    var body: some View {
        HStack {
            if label.isEmpty == false {
                Text(label)
            }
            ForEach(1..<maximumRating + 1, id: \.self) { number in
                image(for: number)
                    .accessibilityLabel("Rating star \(number) of 5.")
                    .accessibilityHint("Select the rating in star numbers.")
                    .foregroundColor(number > rating ? offColor : onColor)
                    .onTapGesture {
                        HapticManager.shared.selectionHaptic()
                        withAnimation { rating = number }
                    }
            }
        }
    }
    
    private func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
}

#Preview {
    RatingView(rating: .constant(4))
}
