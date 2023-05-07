//
//  InformationContainerView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationContainerItem(title: "Your Watchlist", subTitle: "Add everything you want, the Watchlist automatically organizes it for you.", imageName: "film.stack.fill", imageTint: .gray)
            
            InformationContainerItem(title: "Discover what's next", subTitle: "The Discover will help you find your next favorite title.", imageName: "square.grid.3x3.topleft.filled", imageTint: .teal)
            
            InformationContainerItem(title: "Never miss out", subTitle: "Get notifications about the newest releases.", imageName: "bell.fill", imageTint: .orange)
            
            InformationContainerItem(title: "Track your episodes",
                                     subTitle: "Keep track of every episode you've watched.",
                                     imageName: "rectangle.fill.badge.checkmark",
                                     imageTint: .green)
            
            InformationContainerItem(title: "Always Synced",
                                     subTitle: "Your Watchlist is always in sync with your Apple Watch, iPad, Mac, and Apple TV.",
                                     imageName: "icloud.fill")
        }
    }
}

struct InformationContainerView_Previews: PreviewProvider {
    static var previews: some View {
        InformationContainerView()
    }
}
