//
//  PersonView.swift
//  CronicaWatch Watch App
//
//  Created by Alexandre Madeira on 03/08/22.
//

import SwiftUI

struct PersonView: View {
    let id: Int
    let name: String
    let personUrl: URL
    @StateObject private var viewModel: PersonDetailsViewModel
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        _viewModel = StateObject(wrappedValue: PersonDetailsViewModel(id: id))
        self.personUrl = URL(string: "https://www.themoviedb.org/\(MediaType.person.rawValue)/\(id)")!
    }
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: viewModel.person?.personImage) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Rectangle().redacted(reason: .placeholder)
                    } else {
                        ZStack {
                            Rectangle().fill(.secondary)
                            ProgressView()
                        }
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding([.top, .bottom])
                .accessibilityHidden(true)
                
                ShareLink(item: personUrl)
                    .padding(.bottom)
                
                if let credits = viewModel.credits {
                    Divider()
                        .padding([.horizontal, .bottom])
                        .foregroundColor(.secondary)
                    FilmographyListWatch(items: credits)
                    Divider()
                        .padding([.horizontal, .top])
                        .foregroundColor(.secondary)
                }
                
                AttributionView()
                    .padding(.bottom)
            }
        }
        .navigationTitle(name)
        .task {
            await viewModel.load()
        }
    }
    
}

//struct PersonView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonView()
//    }
//}


private struct FilmographyListWatch: View {
    let items: [ItemContent]?
    var body: some View {
        if let items {
            VStack {
                TitleView(title: "Filmography", subtitle: "Know for", image: "list.and.film")
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        SearchItem(item: item)
                    }
                }
            }
        }
    }
}
