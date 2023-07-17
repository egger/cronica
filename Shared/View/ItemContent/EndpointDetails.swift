//
//  EndpointDetails.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 26/11/22.
//

import SwiftUI

struct EndpointDetails: View {
    let title: String
    var endpoint: Endpoints?
    @StateObject private var viewModel = EndpointDetailsViewModel()
    @StateObject private var settings = SettingsStore.shared
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    var body: some View {
        VStack {
            ScrollView {
                switch settings.listsDisplayType {
                case .standard: cardStyle
                case .card: cardStyle
                case .poster: posterStyle
                }
            }
        }
        .overlay {
            if viewModel.isLoading { ProgressView() }
        }
        .actionPopup(isShowing: $showPopup, for: popupType)
        .task {
            if let endpoint {
                await viewModel.loadMoreItems(for: endpoint)
            }
        }
        .navigationTitle(LocalizedStringKey(title))
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
            ForEach(viewModel.items) { item in
                CardFrame(item: item, showPopup: $showPopup, popupConfirmationType: $popupType)
                    .buttonStyle(.plain)
            }
            if endpoint != nil && !viewModel.endPagination && !viewModel.isLoading {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                Task {
                                    if let endpoint {
                                        await viewModel.loadMoreItems(for: endpoint)
                                    }
                                }
                            }
                        }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private var posterStyle: some View {
#if os(iOS)
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.columns,
                  spacing: settings.isCompactUI ? 10 : 20) {
            ForEach(viewModel.items) { item in
                Poster(item: item, showPopup: $showPopup, popupConfirmationType: $popupType)
                    .buttonStyle(.plain)
            }
            if endpoint != nil && !viewModel.endPagination && !viewModel.isLoading {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                Task {
                                    if let endpoint {
                                        await viewModel.loadMoreItems(for: endpoint)
                                    }
                                }
                            }
                        }
                }
            }
        }.padding(.all, settings.isCompactUI ? 10 : nil)
#elseif os(macOS)
        LazyVGrid(columns: DrawingConstants.posterColumns, spacing: 20) {
            ForEach(viewModel.items) { item in
                Poster(item: item, addedItemConfirmation: $showPopup, popupType: $popupType)
                    .buttonStyle(.plain)
            }
            if endpoint != nil && !viewModel.endPagination && !viewModel.isLoading {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                Task {
                                    if let endpoint {
                                        await viewModel.loadMoreItems(for: endpoint)
                                    }
                                }
                            }
                        }
                }
            }
        }.padding()
#endif
    }
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
    static let columns = [GridItem(.adaptive(minimum: 240))]
#else
    static let columns = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160))]
#endif
    static let compactColumns = [GridItem(.adaptive(minimum: 80))]
#if os(macOS)
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
    static let cardColumns = [GridItem(.adaptive(minimum: 240))]
#endif
}
