//
//  AppearanceSetting.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct AppearanceSetting: View {
    @StateObject private var store = SettingsStore.shared
#if os(iOS)
    @StateObject private var icons = IconModel()
#endif
    @State private var disableRowType = false
    var body: some View {
        Form {
#if os(iOS) || os(macOS)
            Section {
#if os(iOS)
                Picker(selection: $store.rowType) {
                    ForEach(WatchlistSubtitleRow.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceRowTypeTitle",
                                       subtitle: "appearanceRowTypeSubtitle")
                }
                .disabled(disableRowType)
#endif
                Picker(selection: $store.watchlistStyle) {
                    ForEach(WatchlistItemType.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceRowStyleTitle",
                                       subtitle: "appearanceRowStyleSubtitle")
                }
                
            } header: {
                Text("appearanceWatchlist")
            }
            .onChange(of: store.watchlistStyle) { newValue in
                if newValue != .list {
                    disableRowType = true
                } else {
                    disableRowType = false
                }
            }
#endif
#if os(iOS)
            Section {
                Picker(selection: $store.currentTheme) {
                    ForEach(AppTheme.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceAppThemeTitle")
                }
                
                Picker(selection: $store.appTheme) {
                    ForEach(AppThemeColors.allCases.sorted { $0.localizableName < $1.localizableName }) { item in
                        HStack {
                            Circle()
                                .fill(item.color)
                                .frame(width: 25)
                            Text(item.localizableName)
                        }
                        .tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceThemeTitle")
                }
                .pickerStyle(.navigationLink)
                
                NavigationLink(destination: AppIconListView()) {
                    HStack {
                        Text("appearanceAppIcon")
                        Spacer()
                        Text(icons.selectedAppIcon.description)
                            .foregroundColor(.secondary)
                    }
                }
                
            } header: {
                Text("appearanceTheme")
            }
#endif
            Section {
                Toggle(isOn: $store.disableTranslucent) {
                    InformationalLabel(title: "disableTranslucentTitle")
                }
            }
            .onChange(of: store.disableTranslucent) { newValue in
                CronicaTelemetry.shared.handleMessage("\(newValue)",
                                                      for: "Translucent UI Settings")
            }
        }
        .navigationTitle("appearanceTitle")
        .task {
            if store.watchlistStyle != .list { disableRowType = true }
        }
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
}

struct AppearanceSetting_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSetting()
    }
}

#if os(iOS)
private struct AppIconListView: View {
    @StateObject private var viewModel = IconModel()
    var body: some View {
        VStack {
            List {
                ForEach(Icon.allCases) { icon in
                    HStack {
                        Image(uiImage: icon.preview)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .cornerRadius(10)
                            .padding(.trailing)
                        Text(icon.description)
                        if viewModel.selectedAppIcon == icon {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(SettingsStore.shared.appTheme.color)
                        }
                    }
                    .onTapGesture {
                        withAnimation { viewModel.updateAppIcon(to: icon) }
                    }
                }
            }
        }
        .navigationTitle("appearanceAppIcon")
    }
}
#endif
