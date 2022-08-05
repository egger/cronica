//
//  PersonItemView.swift
//  Story
//
//  Created by Alexandre Madeira on 05/08/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct PersonStruct: View {
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \PersonItem.name, ascending: true)])
    private var personItems: FetchedResults<PersonItem>
    private let context = PersistenceController.shared 
    var body: some View {
        Section {
            ForEach(personItems) { item in
                PersonItemView(item: item)
                    .contextMenu {
                        ShareLink(item: item.itemUrl)
                        Divider()
                        Button(role: .destructive, action: {
                            withAnimation {
                                context.delete(item)
                            }
                        }, label: {
                            Label("Remove", systemImage: "trash")
                        })
                    }
            }
        } header: {
            Text(NSLocalizedString("Favorite People", comment: ""))
        }
    }
}

struct PersonItemView: View {
    let item: PersonItem
    var body: some View {
        NavigationLink(value: item) {
            HStack {
                WebImage(url: item.image)
                    .placeholder {
                        VStack {
                            ProgressView()
                        }
                        .backgroundStyle(.secondary)
                        .frame(width: DrawingConstants.imageWidth,
                               height: DrawingConstants.imageHeight)
                        .clipShape(Circle())
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .transition(.opacity)
                    .frame(width: DrawingConstants.imageWidth,
                           height: DrawingConstants.imageHeight)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Spacer()
                    Text(item.personName)
                        .lineLimit(DrawingConstants.textLimit)
                    Spacer()
                }
            }
        }
    }
}

//struct PersonItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonItemView(item: PersonItem.example)
//    }
//}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 50
    static let imageHeight: CGFloat = 50
    static let textLimit: Int = 1
}
