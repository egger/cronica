//
//  InformationContainerItem.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 07/05/23.
//

import SwiftUI

struct InformationContainerItem: View {
    var title: String
    var subTitle: String
    var imageName: String
    var imageTint: Color = .blue
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .frame(width: 60)
                .accessibility(hidden: true)
                .foregroundColor(imageTint)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString(title, comment: ""))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .fontDesign(.rounded)
                
                Text(NSLocalizedString(subTitle, comment: ""))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 6)
            .padding([.top, .bottom], 8)
        }
        .padding(.top)
    }
}
struct InformationContainerItem_Previews: PreviewProvider {
    static var previews: some View {
        InformationContainerItem(title: "Preview", subTitle: "Onboarding Experience", imageName: "swift")
    }
}
