//
//  ItemContentView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 27/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentView: View {
    var title: String
    var id: Int
    var type: MediaType
    @StateObject private var viewModel: ItemContentViewModel
    init(title: String, id: Int, type: MediaType) {
        _viewModel = StateObject(wrappedValue: ItemContentViewModel(id: id, type: type))
        self.title = title
        self.id = id
        self.type = type
    }
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Loading")
            }
            VStack {
                ScrollView {
                    ItemContentHeaderView(type: type, title: title)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

//struct ItemContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ItemContentView()
//    }
//}

struct ItemContentHeaderView: View {
    @EnvironmentObject var viewModel: ItemContentViewModel
    let type: MediaType
    let title: String
    var body: some View {
        WebImage(url: viewModel.content?.cardImageLarge)
            .placeholder {
                VStack {
                    if type == .movie {
                        Image(systemName: "film")
                    } else {
                        Image(systemName: "tv")
                    }
                    Text(title)
                        .font(.title3)
                        .lineLimit(1)
                        .padding()
                }
                .background(Color.gray.gradient)
                .ignoresSafeArea(.all)
            }
            .ignoresSafeArea(.all)
    }
}
