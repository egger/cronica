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
            switch settings.sectionStyleType {
            case .list: listStyle
            case .card: cardStyle
            case .poster: ScrollView { posterStyle }
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
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                styleOptions
            }
#endif
        }
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
#if os(iOS) || os(macOS)
    private var styleOptions: some View {
        Menu {
            Picker(selection: $settings.sectionStyleType) {
                ForEach(SectionDetailsPreferredStyle.allCases) { item in
                    Text(item.title).tag(item)
                }
            } label: {
                Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
            }
        } label: {
            Label("sectionStyleTypePicker", systemImage: "circle.grid.2x2")
                .labelStyle(.iconOnly)
        }
    }
#endif
    
    private var listStyle: some View {
        Form {
            Section {
                List {
                    ForEach(viewModel.items) { item in
                        ItemContentRowView(item: item, showPopup: $showPopup, popupType: $popupType)
                    }
                    if endpoint != nil && !viewModel.endPagination && !viewModel.isLoading {
                        CenterHorizontalView {
                            ProgressView("Loading")
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
            }
        }
    }
    
    private var cardStyle: some View {
        ScrollView {
            LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
                ForEach(viewModel.items) { item in
                    ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
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
    }
    
    private var posterStyle: some View {
#if os(iOS)
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.columns,
                  spacing: settings.isCompactUI ? 10 : 20) {
            ForEach(viewModel.items) { item in
                ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
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
                ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
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
