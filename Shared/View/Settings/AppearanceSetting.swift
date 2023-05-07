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
            
            Section {
                Picker(selection: $store.exploreDisplayType) {
                    ForEach(ExplorePreferredDisplayType.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceExploreDisplayType")
                }
            } header: {
                Text("appearanceExplore")
            }
            
            Section {
                Picker(selection: $store.listsDisplayType) {
                    ForEach(ItemContentListPreferredDisplayType.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    InformationalLabel(title: "appearanceListsDisplayType")
                }
                
            } header: {
                Text("appearanceLists")
            }
            
#if os(iOS)
            if UIDevice.isIPhone {
                Section {
                    Toggle(isOn: $store.isCompactUI) {
                        InformationalLabel(title: "appearanceCompactUI", subtitle: "appearanceCompactUISubtitle")
                    }
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
                
                if UIDevice.isIPhone {
                    NavigationLink(destination: AppIconListView(viewModel: icons)) {
                        HStack {
                            Text("appearanceAppIcon")
                            Spacer()
                            Text(icons.selectedAppIcon.description)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
            } header: {
                Text("appearanceTheme")
            }
#endif
            
            Section("accentColor") { accentColor }
            
            Section {
                Toggle(isOn: $store.disableTranslucent) {
                    InformationalLabel(title: "disableTranslucentTitle")
                }
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
    
    private var accentColor: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(AppThemeColors.allCases, content: colorButton)
                }
                .padding(.vertical, 6)
            }
        }
    }
    
    private func colorButton(for item: AppThemeColors) -> some View {
        ZStack {
            Circle()
                .fill(item.color)
            if store.appTheme == item {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .imageScale(.large)
                    .foregroundColor(.white.opacity(0.6))
                    .fontWeight(.black)
                    
            }
        }
        .frame(width: 30)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(item == store.appTheme ? [.isButton, .isSelected] : .isButton )
        .accessibilityLabel(item.localizableName)
        .padding(.horizontal, 4)
        .onTapGesture {
            withAnimation {
                store.appTheme = item
            }
        }
    }
    
    #if os(iOS)
    #endif
}

struct AppearanceSetting_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AppearanceSetting()
#if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
#endif
        }
    }
}

#if os(iOS)
private struct AppIconListView: View {
    @ObservedObject var viewModel = IconModel()
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
                NavigationLink(destination: FeedbackSettingsView()) {
                    InformationalLabel(title: "appIconFeedbackTitle")
                }
            }
        }
        .navigationTitle("appearanceAppIcon")
    }
}
#endif

