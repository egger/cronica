//
//  AppearanceSetting.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 13/12/22.
//

import SwiftUI

struct AppearanceSetting: View {
    @StateObject private var store = SettingsStore.shared
#if os(iOS)
    @StateObject private var icons = IconModel()
#endif
    var body: some View {
        Form {
#if os(iOS)
            if UIDevice.isIPhone {
                Section("Details Page") {
                    Toggle("Prefer Poster in Details Page", isOn: $store.usePostersAsCover)
                }
            }
#endif
            Section {
                Picker(selection: $store.watchlistStyle) {
                    ForEach(SectionDetailsPreferredStyle.allCases) { item in
#if os(tvOS)
                        if item != SectionDetailsPreferredStyle.list {
                            Text(item.title).tag(item)
                        }
#else
                        Text(item.title).tag(item)
#endif
                    }
                } label: {
                    Text("appearanceRowStyleTitle")
                }
                .tint(.secondary)
#if !os(tvOS)
                Picker(selection: $store.sectionStyleType) {
                    ForEach(SectionDetailsPreferredStyle.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    Text("appearanceSectionDetailsTitle")
                }
                .tint(.secondary)
                Picker(selection: $store.listsDisplayType) {
                    ForEach(ItemContentListPreferredDisplayType.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    Text("appearanceHorizontalListsTitle")
                }
                .tint(.secondary)
                Picker(selection: $store.upNextStyle) {
                    ForEach(UpNextDetailsPreferredStyle.allCases) { item in
                        Text(item.title).tag(item)
                    }
                } label: {
                    Text("appearanceUpNextTitle")
                }
                .tint(.secondary)
#endif
            } header: {
                Text("appearanceStyle")
            }
            
#if os(iOS)
            if UIDevice.isIPhone {
                Section {
                    Toggle(isOn: $store.isCompactUI) {
                        Text("appearanceCompactUI")
                        Text("appearanceCompactUISubtitle")
                    }
                }
            }
#endif
            
#if !os(tvOS)
            Section {
                Toggle("Show Date in Watchlist", isOn: $store.showDateOnWatchlist)
            }
#endif
            
#if os(iOS)
            Section("appearanceAppThemeTitle") {
                Picker(selection: $store.currentTheme) {
                    ForEach(AppTheme.allCases) { item in
                        Text(item.localizableName).tag(item)
                    }
                } label: {
                    Text("appearanceAppThemeTitle")
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)
                .tint(.secondary)
            }
            
            Section("accentColor") { accentColor }
            
            if UIDevice.isIPhone {
                Section("appearanceAppIcon") {
                    iconsGrid
                }
            }
#endif
            
            Section {
                Toggle(isOn: $store.disableTranslucent) {
                    Text("disableTranslucentTitle")
                }
            }
        }
        .navigationTitle("appearanceTitle")
#if os(macOS)
        .formStyle(.grouped)
#endif
    }
    
    private var accentColor: some View {
        VStack(alignment: .leading) {
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(AppThemeColors.allCases, content: colorButton)
                    }
                    .padding(.vertical, 6)
                    .onAppear {
                        withAnimation { proxy.scrollTo(store.appTheme, anchor: .topLeading) }
                    }
                }
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
    private var iconsGrid: some View {
        HStack {
            ForEach(Icon.allCases) { icon in
                Image(uiImage: icon.preview)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(store.appTheme.color, lineWidth: icons.selectedAppIcon == icon ? 6 : 0)
                    )
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.trailing)
                    .onTapGesture {
                        withAnimation { icons.updateAppIcon(to: icon) }
                    }
            }
        }
        .padding(.vertical, 4)
    }
#endif
}

#Preview {
    AppearanceSetting()
}
