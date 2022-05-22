//
//  SeasonListView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 02/04/22.
//

import SwiftUI

struct HorizontalSeasonView: View {
    var numberOfSeasons: [Int]
    var tvId: Int
    @State private var selectedSeason: Int = 1
    @StateObject private var viewModel: SeasonViewModel
    @State private var showEpisodeDetails: Bool = false
    @State private var selectedEpisode: Episode?
    init(numberOfSeasons: [Int], tvId: Int) {
        _viewModel = StateObject(wrappedValue: SeasonViewModel())
        self.numberOfSeasons = numberOfSeasons
        self.tvId = tvId
    }
    var body: some View {
        VStack {
            HStack {
                Picker("Seasons", selection: $selectedSeason) {
                    ForEach(numberOfSeasons, id: \.self) { season in
                        Text("Season \(season)").tag(season)
                    }
                }
                .pickerStyle(.menu)
                .unredacted()
                .onChange(of: selectedSeason) { value in
                    if selectedSeason != 1 {
                        load()
                    }
                }
                .padding(.leading)
                .padding(.bottom, 1)
                Spacer()
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    if let season = viewModel.season?.episodes {
                        ForEach(season) { item in
                            EpisodeFrameView(episode: item)
                                .frame(width: 160, height: 200)
                                .onTapGesture {
                                    selectedEpisode = item
                                    showEpisodeDetails.toggle()
                                }
                                .padding([.leading, .trailing], 4)
                                .padding(.leading, item.id == season.first!.id ? 16 : 0)
                                .padding(.trailing, item.id == season.last!.id ? 16 : 0)
                                .sheet(isPresented: $showEpisodeDetails, content: {
                                    NavigationView {
                                        EpisodeDetailsView(item: $selectedEpisode)
                                            .navigationTitle(selectedEpisode?.itemTitle ?? "")
                                            .navigationBarTitleDisplayMode(.inline)
                                            .toolbar {
                                                ToolbarItem(placement: .navigationBarTrailing, content: {
                                                    Button(action: { showEpisodeDetails.toggle() }, label: {
                                                        Text("Done")
                                                    })
                                                })
                                            }
                                    }
                                })
                        }
                        .padding(0)
                        .buttonStyle(.plain)
                    }
                }
                .padding(0)
            }
            .padding(0)
            .task {
                load()
            }
        }
        .padding(0)
        .redacted(reason: viewModel.isLoading ? .placeholder : [] )
    }
    
    @Sendable
    private func load() {
        Task {
            await self.viewModel.load(id: self.tvId, season: self.selectedSeason)
        }
    }
}

struct HorizontalSeasonView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalSeasonView(numberOfSeasons: Array(1...8), tvId: 1419)
    }
}

private struct DrawingConstants {
    static let imageWidth: CGFloat = 120
    static let imageHeight: CGFloat = 80
    static let imageRadius: CGFloat = 4
    static let textLimit: Int = 1
}
