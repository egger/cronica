//
//  ItemContentHeaderView.swift
//  CronicaTV
//
//  Created by Alexandre Madeira on 28/10/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ItemContentHeaderView: View {
    let title: String
    @EnvironmentObject var viewModel: ItemContentViewModel
    var body: some View {
        ZStack {
            WebImage(url: viewModel.content?.cardImageOriginal)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 1920, height: 1080)
            VStack {
                Spacer()
                ZStack {
                    Color.black.opacity(0.4)
                        .frame(height: 400)
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
                        .frame(height: 600)
                        .mask {
                            VStack(spacing: 0) {
                                LinearGradient(colors: [Color.black.opacity(0),
                                                        Color.black.opacity(0.383),
                                                        Color.black.opacity(0.707),
                                                        Color.black.opacity(0.924),
                                                        Color.black],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                .frame(height: 400)
                                Rectangle()
                            }
                        }
                }
            }
            .padding(.zero)
            .ignoresSafeArea()
            .frame(width: 1920, height: 1080)
            VStack(alignment: .leading) {
                Spacer()
                HStack(alignment: .bottom) {
                    VStack {
                        Text(title)
                            .lineLimit(1)
                            .font(.title3)
                        GlanceInfo(info: viewModel.content?.itemInfo)
                            .padding([.bottom, .top], 6)
                        ItemContentOverview(overview: viewModel.content?.itemOverview)
                    }
                    .frame(maxWidth: 900)
                    Spacer()
                    VStack {
                        HStack {
                            Button(action: {
                                if let item = viewModel.content {
                                    viewModel.updateWatchlist(with: item)
                                }
                            }, label: {
                                Text(viewModel.isInWatchlist ? "Remove from List" : "Add to List")
                            })
                            Button(action: {
                                viewModel.updateMarkAs(markAsWatched: !viewModel.isWatched)
                            }, label: {
                                Text(viewModel.isWatched ? "Remove from Watched" : "Mark as Watched")
                            })
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
}

private struct GlanceInfo: View {
    var info: String?
    var body: some View {
        if let info {
            Text(info)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
