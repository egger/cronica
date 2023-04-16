//
//  EndpointDetails.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 26/11/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
struct EndpointDetails: View {
    let title: String
    var endpoint: Endpoints?
    @StateObject private var viewModel = EndpointDetailsModel()
    @StateObject private var settings = SettingsStore.shared
    @State private var showConfirmation = false
    var body: some View {
        ZStack {
            if viewModel.isLoading { ProgressView() }
            ScrollView {
                VStack {
                    if settings.listsDisplayType == .card {
                        cardStyle
                    } else {
                        posterStyle
                    }
                    if !viewModel.items.isEmpty {
                        AttributionView()
                    }
                }
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation, message: "addedToWatchlist")
        }
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
                CardFrame(item: item, showConfirmation: $showConfirmation)
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
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.columns,
                  spacing: settings.isCompactUI ? 10 : 20) {
            ForEach(viewModel.items) { item in
                Poster(item: item, addedItemConfirmation: $showConfirmation)
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
        .padding(.all, settings.isCompactUI ? 10 : nil)
    }
}

@MainActor
private class EndpointDetailsModel: ObservableObject {
    @Published var items = [ItemContent]()
    private var page = 1
    @Published var startPagination: Bool = false
    @Published var endPagination: Bool = false
    @Published var isLoading = true
    
    func loadMoreItems(for endpoint: Endpoints) async {
        do {
            let result = try await NetworkService.shared.fetchItems(from: "\(endpoint.type.rawValue)/\(endpoint.rawValue)", page: String(page))
            items.append(contentsOf: result)
            if !items.isEmpty {
                page += 1
                startPagination = false
            }
            if result.isEmpty { endPagination = true }
            withAnimation { isLoading = false }
        } catch {
            if Task.isCancelled { return }
            print(error.localizedDescription)
        }
    }
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
    static let columns: CGFloat = 160
#else
    static let columns = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160))]
    static let compactColumns = [GridItem(.adaptive(minimum: 80))]
#endif
}
#endif
