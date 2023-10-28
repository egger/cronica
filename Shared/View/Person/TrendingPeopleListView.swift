//
//  TrendingPeopleListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrendingPeopleListView: View {
	@EnvironmentObject var viewModel: SearchViewModel
    var body: some View {
		VStack {
			if !viewModel.trendingPeople.isEmpty {
				TitleView(title: "Trending People", subtitle: "This Week")
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack {
						ForEach(viewModel.trendingPeople) { people in
							VStack {
								NavigationLink(value: people) {
									WebImage(url: people.personImage)
										.resizable()
										.placeholder {
											ZStack {
												Circle().fill(.gray.gradient)
												Image(systemName: "person")
													.foregroundColor(.white)
											}
										}
										.aspectRatio(contentMode: .fill)
										.frame(width: 80, height: 80, alignment: .center)
										.clipShape(Circle())
										.contextMenu {
#if !os(tvOS)
											ShareLink(item: people.itemURL)
#endif
										}
										.shadow(radius: 2)
								}
								Text(people.name)
									.font(.caption)
									.lineLimit(2)
								Spacer()
							}
							.frame(width: 80)
							.padding([.leading, .trailing], 4)
							.padding(.leading, people.id == viewModel.trendingPeople.first?.id ? 16 : 0)
							.padding(.trailing, people.id == viewModel.trendingPeople.last!.id ? 16 : 0)
							.padding(.top, 8)
							.padding(.bottom)
						}
					}
				}
				.redacted(reason: viewModel.isLoadingTrendingPeople ? .placeholder : [])
				Divider()
					.padding(.horizontal)
			}
		}
    }
}

struct TrendingPeopleListView_Previews: PreviewProvider {
    static var previews: some View {
        TrendingPeopleListView()
    }
}
