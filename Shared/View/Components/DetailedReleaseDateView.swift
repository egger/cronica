//
//  DetailedReleaseDateView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 27/06/23.
//

import SwiftUI

struct DetailedReleaseDateView: View {
    let item: [ReleaseDatesResult]?
    @State private var dates = [ReleaseDateDisplay]()
    @State private var isLoading = true
    @Binding var dismiss: Bool
    var body: some View {
        NavigationStack {
            Form {
                List {
                    ForEach(dates) { date in
                        VStack(alignment: .leading) {
                            Text(date.releaseType.localizedTitle)
                                .font(.callout)
                                .fontWeight(.semibold)
                            Text(date.formattedDate)
                                .font(.callout)
                            Text(date.itemRegion)
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .toolbar {
                Button("Done") { dismiss.toggle() }
            }
            .onAppear(perform: load)
            .navigationTitle("releaseDates")
#if os(macOS)
            .formStyle(.grouped)
#elseif os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
        }
        .presentationDetents([.medium])
        .appTheme()
        .appTint()
    }
    
    private func load() {
        guard let item else { return }
        for content in item {
            if let iso = content.iso31661 {
                if iso.lowercased() == Locale.userRegion.lowercased() {
                    let result = fetchDates(content.releaseDates, region: iso)
                    guard let result else { return }
                    dates = result
                    isLoading = false
                }
                // If the user country is not found in the ISO, then US is used.
                if iso.lowercased() == "us" {
                    let result = fetchDates(content.releaseDates, region: "us")
                    guard let result else { return }
                    if dates.isEmpty { dates = result }
                    isLoading = false
                }
            }
        }
    }
    
    private func fetchDates(_ dates: [ReleaseDate]?, region: String?) -> [ReleaseDateDisplay]? {
        guard let dates else { return nil }
        var result = [ReleaseDateDisplay]()
        for date in dates {
            if let type = date.type {
                if type == ReleaseDateType.theatrical.toInt {
                    let content = getReleaseDateType(for: date, type: ReleaseDateType.theatrical, region: region)
                    if let content {
                        if !result.contains(where: { $0.releaseType == .theatrical }) {
                            result.append(content)
                        }
                    }
                }
                if type == ReleaseDateType.digital.toInt {
                    let content = getReleaseDateType(for: date, type: ReleaseDateType.digital, region: region)
                    if let content {
                        if !result.contains(where: { $0.releaseType == .digital }) {
                            result.append(content)
                        }
                    }
                }
                if type == ReleaseDateType.tv.toInt {
                    let content = getReleaseDateType(for: date, type: ReleaseDateType.tv, region: region)
                    if let content {
                        result.append(content)
                    }
                }
                if type == ReleaseDateType.premiere.toInt {
                    let content = getReleaseDateType(for: date, type: ReleaseDateType.premiere, region: region)
                    if let content {
                        if !result.contains(where: { $0.releaseType == .premiere }) {
                            result.append(content)
                        }
                    }
                }
            }
            if !result.isEmpty {
                self.dates = result
            }
        }
        return nil
    }
    
    private func getReleaseDateType(for date: ReleaseDate, type release: ReleaseDateType, region: String?) -> ReleaseDateDisplay? {
        let convertedDate = releaseToDate(for: date)
        guard let convertedDate else { return nil }
        let stringDate = convertedDate.convertDateToString()
        let regionName = getLocalizedCountryNameFromISOCode(code: region)
        let result = ReleaseDateDisplay(formattedDate: stringDate, releaseType: release, region: regionName)
        return result
    }
    
    private func releaseToDate(for item: ReleaseDate) -> Date? {
        guard let release = item.releaseDate else { return nil }
        return String.releaseDateFormatter.date(from: release)
    }
    
    func getLocalizedCountryNameFromISOCode(code: String?) -> String? {
        guard let code else { return nil }
        guard let countryName = Locale.current.localizedString(forRegionCode: code) else {
            return nil
        }
        return countryName
    }
}

struct ReleaseDateDisplay: Identifiable, Codable {
    var id = UUID()
    let formattedDate: String
    let releaseType: ReleaseDateType
    let region: String?
}

extension ReleaseDateDisplay {
    var itemRegion: String {
        region ?? "Not Found"
    }
}
