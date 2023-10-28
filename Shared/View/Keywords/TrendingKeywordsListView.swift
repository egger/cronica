//
//  TrendingKeywordsListView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 10/08/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct TrendingKeywordsListView: View {
	@EnvironmentObject var viewModel: SearchViewModel
	private let columns = [GridItem(.adaptive(minimum: 160))]
    var body: some View {
		VStack {
			if !viewModel.trendingKeywords.isEmpty {
				TitleView(title: "Trending Keywords").unredacted()
				ScrollView {
					LazyVGrid(columns: columns, spacing: 20) {
						ForEach(viewModel.trendingKeywords) { keyword in
                            if keyword.image != nil {
                                NavigationLink(value: keyword) {
                                    WebImage(url: keyword.image, options: [.continueInBackground, .highPriority])
                                        .resizable()
                                        .placeholder {
                                            ZStack {
                                                Rectangle().fill(.gray.gradient)
                                            }
                                        }
                                        .aspectRatio(contentMode: .fill)
                                        .overlay {
                                            ZStack {
                                                Rectangle().fill(.black.opacity(0.5))
                                                VStack {
                                                    Spacer()
                                                    HStack {
                                                        Text(keyword.name)
                                                            .foregroundColor(.white)
                                                            .font(.subheadline)
                                                            .fontWeight(.semibold)
                                                            .multilineTextAlignment(.leading)
                                                            .lineLimit(2)
                                                        Spacer()
                                                    }
                                                    .padding(.horizontal)
                                                    .padding(.bottom, 8)
                                                }
                                            }
                                        }
                                        .frame(width: 160, height: 100, alignment: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                        .shadow(radius: 2)
                                        .buttonStyle(.plain)
                                }
                                .disabled(viewModel.isLoadingTrendingKeywords)
                                .frame(width: 160, height: 100, alignment: .center)
                            }
						}
					}
					.padding([.horizontal, .bottom])
				}
			}
		}
		.redacted(reason: viewModel.isLoadingTrendingKeywords ? .placeholder : [])
    }
}

#Preview {
    TrendingKeywordsListView()
}
