//
//  CompanyDetails.swift
//  Story
//
//  Created by Alexandre Madeira on 05/02/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct CompanyDetails: View {
    let company: ProductionCompany
    @State private var showConfirmation = false
    @StateObject private var viewModel = CompanyDetailsViewModel()
    var body: some View {
        ZStack {
            if !viewModel.isLoaded { ProgressView() }
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: DrawingConstants.columns))], spacing: 20) {
                        ForEach(viewModel.items) { item in
                            CardFrame(item: item, showConfirmation: $showConfirmation)
                                .buttonStyle(.plain)
                        }
                        if viewModel.isLoaded && !viewModel.endPagination {
                            CenterHorizontalView {
                                ProgressView()
                                    .padding()
                                    .onAppear {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
            }
            .redacted(reason: viewModel.isLoaded ? [] : .placeholder)
            .navigationTitle(company.name)
            .onAppear {
                Task {
                    await viewModel.load(company.id)
                }
            }
            .toolbar {
                if let url = URL(string: "https://www.themoviedb.org/company/\(company.id)/") {
                    ShareLink(item: url)
                }
            }
            .navigationDestination(for: ItemContent.self) { item in
#if os(macOS)
                ItemContentDetailsView(id: item.id, title: item.itemTitle,
                                       type: item.itemContentMedia, handleToolbarOnPopup: true)
#else
                ItemContentDetails(title: item.itemTitle, id: item.id, type: item.itemContentMedia)
#endif
            }
            .navigationDestination(for: Person.self) { person in
                PersonDetailsView(title: person.name, id: person.id)
            }
            .navigationDestination(for: [String:[ItemContent]].self) { item in
                let keys = item.map { (key, _) in key }
                let value = item.map { (_, value) in value }
                ItemContentCollectionDetails(title: keys[0], items: value[0])
            }
            .navigationDestination(for: [Person].self) { items in
                DetailedPeopleList(items: items)
            }
            .navigationDestination(for: ProductionCompany.self) { item in
                CompanyDetails(company: item)
            }
            ConfirmationDialogView(showConfirmation: $showConfirmation)
        }
    }
}

//struct CompanyDetails_Previews: PreviewProvider {
//    static private let company = ProductionCompany(name: "PlayStation Productions", id: 125281)
//    static var previews: some View {
//        CompanyDetails(company: company)
//    }
//}

struct CompaniesListView: View {
    let companies: [ProductionCompany]
    var body: some View {
        if companies.isEmpty {
            
        } else {
            List(companies, id: \.self) { item in
                NavigationLink(value: item) {
                    HStack {
                        ZStack {
                            Rectangle()
                                .fill(.white.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            WebImage(url: item.logoUrl)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 20)
                                .padding()
                        }
                        .frame(width: 40, height: 20)
                        .padding()
                        Text(item.name)
                    }
                }
            }
            .navigationTitle("companiesTitle")
        }
    }
}

class CompanyDetailsViewModel: ObservableObject {
    var page = 1
    @Published var items = [ItemContent]()
    @Published var startPagination = false
    @Published var endPagination = false
    @Published var isLoaded = false
    
    @MainActor
    func load(_ id: Int) async {
        do {
            let movies = try await NetworkService.shared.fetchCompanyFilmography(type: .movie,
                                                                                 page: page,
                                                                                 company: id)
            let shows = try await NetworkService.shared.fetchCompanyFilmography(type: .tvShow,
                                                                                page: page,
                                                                                company: id)
            let result = movies + shows
            if result.isEmpty {
                endPagination = true
                return
            } else {
                page += 1
            }
            items.append(contentsOf: result.sorted { $0.itemPopularity > $1.itemPopularity })
            if !startPagination { startPagination = true }
            if !isLoaded {
                DispatchQueue.main.async {
                    self.isLoaded = true
                }
            }
        } catch {
            if Task.isCancelled { return }
            let message = "Company ID: \(id), error: \(error.localizedDescription)"
            CronicaTelemetry.shared.handleMessage(message, for: "CompanyDetailsViewModel.load()")
        }
    }
}

private struct DrawingConstants {
#if os(macOS)
    static let columns: CGFloat = 240
#else
    static let columns: CGFloat = UIDevice.isIPad ? 240 : 160
#endif
}