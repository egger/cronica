//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

/// Renders the Settings UI for each OS, support iOS, macOS, and tvOS.
struct SettingsView: View {
#if os(iOS)
    static let tag: Screens? = .settings
    @State private var showPolicy = false
    @State private var showWhatsNew = false
#elseif os(tvOS)
    @StateObject private var store = SettingsStore.shared
#endif
    var body: some View {
        settings
    }
    
    private var settings: some View {
#if os(iOS)
        NavigationStack {
            Form {
                Section {
                    NavigationLink(value: SettingsScreens.behavior) {
                        settingsLabel(title: "settingsBehaviorTitle", icon: "hand.tap", color: .gray)
                    }
                    NavigationLink(value: SettingsScreens.appearance) {
                        settingsLabel(title: "settingsAppearanceTitle", icon: "paintbrush", color: .blue)
                    }
                    NavigationLink(value: SettingsScreens.sync) {
                        settingsLabel(title: "settingsSyncTitle", icon: "arrow.triangle.2.circlepath", color: .green)
                    }
                    NavigationLink(value: SettingsScreens.notifications) {
                        settingsLabel(title: "settingsNotificationTitle", icon: "bell", color: .red)
                    }
                    NavigationLink(destination: RegionContentSettings()) {
                        settingsLabel(title: "settingsRegionContentTitle", icon: "globe", color: .purple)
                    }
                }
                
                Section {
                    Button {
                        showPolicy.toggle()
                    } label: {
                        settingsLabel(title: "Privacy Policy", icon: "hand.raised", color: .indigo)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showPolicy) {
                        if let url = URL(string: "https://alexandremadeira.dev/cronica/privacy") {
                            SFSafariViewWrapper(url: url)
                                .appTint()
                                .appTheme()
                        }
                    }
                }
                
                Section {
                    Button {
                        showWhatsNew.toggle()
                    } label: {
                        settingsLabel(title: "What's New", icon: "sparkles", color: .yellow)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showWhatsNew) {
                        ChangelogView(showChangelog: $showWhatsNew)
                            .appTint()
                            .appTheme()
                    }
                    NavigationLink(destination: TipJarSetting()) {
                        settingsLabel(title: "tipJarTitle", icon: "heart", color: .red)
                    }
                    
                    NavigationLink(value: SettingsScreens.about) {
                        settingsLabel(title: "aboutTitle", icon: "info.circle", color: .black)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: SettingsScreens.self) { settings in
                switch settings {
                case .about: AboutSettings()
                case .appearance: AppearanceSetting()
                case .behavior: BehaviorSetting()
                case .developer: DeveloperView()
                case .notifications: NotificationsSettingsView()
                case .sync: SyncSetting()
                case .tipJar: TipJarSetting()
                default: BehaviorSetting()
                }
            }
        }
#elseif os(macOS)
        TabView {
            BehaviorSetting()
                .tabItem { Label("settingsBehaviorTitle", systemImage: "cursorarrow.click") }
            
            AppearanceSetting()
                .tabItem { Label("settingsAppearanceTitle", systemImage: "moon.stars") }
            
            SyncSetting()
                .tabItem { Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath") }
            
            RegionContentSettings()
                .tabItem { Label("settingsRegionContentTitle", systemImage: "globe")  }
            
            TipJarSetting()
                .tabItem { Label("tipJar", systemImage: "heart") }
            
            AboutSettings()
                .tabItem { Label("aboutTitle", systemImage: "info.circle") }
        }
        .frame(minWidth: 420, idealWidth: 500, minHeight: 320, idealHeight: 320)
        .tabViewStyle(.automatic)
#elseif os(tvOS)
        NavigationStack {
            Form {
                Section("Watchlist") {
                    Toggle("removeFromPinOnWatchedTitle", isOn: $store.removeFromPinOnWatched)
                    Toggle("showConfirmationOnRemovingItem", isOn: $store.showRemoveConfirmation)
                }
                
                Section {
                    NavigationLink("settingsSyncTitle", destination: SyncSetting()) 
                    NavigationLink("settingsRegionContentTitle", destination:  RegionContentSettings())
                }
                
                Section {
                    NavigationLink("tipJar", destination: TipJarSetting())
                }
            }
            .navigationTitle("Settings")
        }
#endif
    }
    
    private func settingsLabel(title: String, icon: String, color: Color) -> some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30, alignment: .center)
            .padding(.trailing, 8)
            .accessibilityHidden(true)
            Text(LocalizedStringKey(title))
        }
        .padding(.vertical, 2)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
