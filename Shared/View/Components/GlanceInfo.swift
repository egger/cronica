//
//  GlanceInfo.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/05/23.
//

import SwiftUI

struct GlanceInfo: View {
    var info: String?
    var body: some View {
        if let info {
            Text(info)
                .font(.callout)
        }
    }
}

struct GlanceInfo_Previews: PreviewProvider {
    static var previews: some View {
        GlanceInfo(info: ItemContent.example.itemInfo)
    }
}
