//
//  ItemContentOverview.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI

struct ItemContentOverview: View {
   var overview: String?
   var body: some View {
       if let overview {
           VStack(alignment: .leading) {
               Text(overview)
                   .font(.callout)
                   .lineLimit(2)
           }
       }
   }
}

struct ItemContentOverview_Previews: PreviewProvider {
    static var previews: some View {
        ItemContentOverview(overview: ItemContent.previewContent.itemOverview)
    }
}
