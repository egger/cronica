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
    @State private var showConfirmation = false
    var body: some View {
        ZStack {
            if viewModel.isLoading { ProgressView() }
            ScrollView {
                VStack {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: DrawingConstants.columns ))], spacing: 20) {
                        ForEach(viewModel.items) { item in
#if os(macOS)
                            Poster(item: item, addedItemConfirmation: $showConfirmation)
                                .buttonStyle(.plain)
#else
                            CardFrame(item: item, showConfirmation: $showConfirmation)
                                .buttonStyle(.plain)
#endif
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
    static let columns: CGFloat = UIDevice.isIPad ? 240 : 160 
#endif
}
#endif
