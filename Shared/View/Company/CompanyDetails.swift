//
//  CompanyDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 05/02/23.
//

import SwiftUI

struct CompanyDetails: View {
    let company: ProductionCompany
    @State private var showPopup = false
    @State private var popupType: ActionPopupItems?
    @StateObject private var viewModel = CompanyDetailsViewModel()
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        ZStack {
            if !viewModel.isLoaded { ProgressView() }
            
            VStack {
                ScrollView {
                    if settings.listsDisplayType == .poster {
                        posterStyle
                    } else {
                        cardStyle
                    }
                }
            }
            .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
            .navigationTitle(company.name)
#if os(iOS)
            .navigationBarTitleDisplayMode(.large)
#endif
            .onAppear {
                Task {
                    await viewModel.load(company.id)
                }
            }
            .toolbar {
#if os(iOS) || os(macOS)
                if let url = URL(string: "https://www.themoviedb.org/company/\(company.id)/") {
                    ShareLink(item: url)
                }
#endif
            }
            .actionPopup(isShowing: $showPopup, for: popupType)
        }
    }
    
    @ViewBuilder
    private var cardStyle: some View {
        LazyVGrid(columns: DrawingConstants.columns, spacing: 20) {
            ForEach(viewModel.items) { item in
                ItemContentCardView(item: item, showPopup: $showPopup, popupType: $popupType)
                    .buttonStyle(.plain)
            }
            if viewModel.isLoaded && !viewModel.endPagination {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                Task {
                                    await viewModel.load(company.id)
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
        LazyVGrid(columns: settings.isCompactUI ? DrawingConstants.compactColumns : DrawingConstants.posterColumns,
                  spacing: settings.isCompactUI ? 10 : 20) {
            ForEach(viewModel.items) { item in
                ItemContentPosterView(item: item, showPopup: $showPopup, popupType: $popupType)
                    .buttonStyle(.plain)
            }
            if viewModel.isLoaded && !viewModel.endPagination {
                CenterHorizontalView {
                    ProgressView()
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                Task {
                                    await viewModel.load(company.id)
                                }
                            }
                        }
                }
            }
        }
                  .padding(.all, settings.isCompactUI ? 10 : nil)
    }
}

struct CompanyDetails_Previews: PreviewProvider {
    static private let company = ProductionCompany(name: "PlayStation Productions",
                                                   id: 125281, logoPath: nil, originCountry: nil, description: nil)
    static var previews: some View {
        CompanyDetails(company: company)
    }
}

private struct DrawingConstants {
#if os(macOS) || os(tvOS)
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: 240))]
#else
    static let columns: [GridItem] = [GridItem(.adaptive(minimum: UIDevice.isIPad ? 240 : 160 ))]
#endif
    static let compactColumns: [GridItem] = [GridItem(.adaptive(minimum: 80))]
    static let posterColumns = [GridItem(.adaptive(minimum: 160))]
}
