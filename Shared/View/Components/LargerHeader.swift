//
//  LargerHeader.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/05/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct LargerHeader: View {
    let title: String
    let type: MediaType
    @EnvironmentObject var viewModel: ItemContentViewModel
    var body: some View {
#if os(macOS)
        image
#else
        image
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding()
            .shadow(radius: 5)
#endif
    }
    
    private var image: some View {
        WebImage(url: viewModel.content?.cardImageOriginal)
            .resizable()
            .placeholder {
                ZStack {
                    Rectangle().fill(Color.gray.gradient)
                    Image(systemName: type == .tvShow ? "tv" : "film")
                        .foregroundColor(.secondary)
                        .font(.title)
                        .fontWeight(.semibold)
                }
                .frame(height: 500)
                .padding(.zero)
            }
            .aspectRatio(contentMode: .fill)
            .overlay {
                ZStack {
                    if viewModel.content?.cardImageOriginal != nil {
                        VStack {
                            Spacer()
                            ZStack(alignment: .bottom) {
                                Color.black.opacity(0.8)
                                    .frame(height: 150)
                                    .mask {
                                        LinearGradient(colors: [Color.black,
                                                                Color.black.opacity(0.924),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                    }
                                Rectangle()
                                    .fill(.ultraThinMaterial)
                                    .frame(height: 140)
                                    .mask {
                                        LinearGradient(colors: [Color.black,
                                                                Color.black.opacity(0.924),
                                                                Color.black.opacity(0.707),
                                                                Color.black.opacity(0.383),
                                                                Color.black.opacity(0)],
                                                       startPoint: .bottom,
                                                       endPoint: .top)
                                        .frame(height: 150)
                                    }
                            }
                        }
                    }
                    VStack(alignment: .leading) {
                        Spacer()
#if os(macOS)
                        informations
                            .padding()
#else
                        ViewThatFits {
                            informations.padding()
                            compactInfo.padding(.bottom)
                        }
#endif
                    }
                }
            }
            .transition(.scale)
    }
    
    private var informations: some View {
        HStack(alignment: .bottom) {
            VStack {
                Text(title)
                    .lineLimit(1)
                    .font(.title)
                    .foregroundColor(.white)
                GlanceInfo(info: viewModel.content?.itemInfo)
                    .padding(.bottom, 6)
                    .foregroundColor(.white.opacity(0.8))
                DetailWatchlistButton()
                    .environmentObject(viewModel)
            }
            .frame(maxWidth: 600)
            .padding(.horizontal)
            Spacer()
#if os(iOS)
            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: "About",
                            type: type)
            .groupBoxStyle(TransparentGroupBox())
            .padding([.horizontal, .top])
            .frame(maxWidth: 500)
#elseif os(macOS)
            OverviewBoxView(overview: viewModel.content?.itemOverview,
                            title: "About",
                            type: .movie)
            .foregroundColor(.white)
            .padding([.horizontal, .top])
            .frame(maxWidth: 500)
#endif
            Spacer()
        }
    }
    
    private var compactInfo: some View {
        CenterHorizontalView {
            VStack {
                GlanceInfo(info: viewModel.content?.itemInfo)
                    .padding(.bottom, 6)
                    .foregroundColor(.white.opacity(0.8))
                DetailWatchlistButton()
                    .environmentObject(viewModel)
            }
        }
    }
}
