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
        VStack {
            switch settings.sectionStyleType {
            case .list: listStyle
            case .poster: ScrollView { posterStyle }
            case .card: ScrollView { cardStyle }
            }
        }
        .overlay {
            if !viewModel.isLoaded { ProgressView() }
        }
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                styleOptions
            }
#endif
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
                    if viewModel.isLoaded && !viewModel.endPagination {
                        CenterHorizontalView {
                            ProgressView("Loading")
                                .padding(.horizontal)
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
            }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
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
