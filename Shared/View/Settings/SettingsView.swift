//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI
#if os(iOS) || os(macOS)
/// Renders the Settings UI for each OS, support iOS, macOS, and tvOS.
struct SettingsView: View {
#if os(iOS)
    static let tag: Screens? = .settings
    @State private var showPolicy = false
    @State private var showWhatsNew = false
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
                        SettingsLabelWithIcon(title: "settingsBehaviorTitle", icon: "hand.tap", color: .gray)
                    }
                    NavigationLink(value: SettingsScreens.appearance) {
                        SettingsLabelWithIcon(title: "settingsAppearanceTitle", icon: "paintbrush", color: .blue)
                    }
                    NavigationLink(value: SettingsScreens.sync) {
                        SettingsLabelWithIcon(title: "settingsSyncTitle", icon: "arrow.triangle.2.circlepath", color: .green)
                    }
                    NavigationLink(value: SettingsScreens.notifications) {
                        SettingsLabelWithIcon(title: "settingsNotificationTitle", icon: "bell", color: .red)
                    }
                    NavigationLink(destination: RegionContentSettings()) {
                        SettingsLabelWithIcon(title: "settingsRegionContentTitle", icon: "globe", color: .purple)
                    }
                }
                
                Section {
                    Button {
                        showPolicy.toggle()
                    } label: {
                        SettingsLabelWithIcon(title: "Privacy Policy", icon: "hand.raised", color: .indigo)
                    }
                    .buttonStyle(.plain)
                    .fullScreenCover(isPresented: $showPolicy) {
                        SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                    }
                }
                
                Section {
                    Button {
                        showWhatsNew.toggle()
                    } label: {
                        SettingsLabelWithIcon(title: "What's New", icon: "sparkles", color: .yellow)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showWhatsNew) {
                        ChangelogView(showChangelog: $showWhatsNew)
                    }
                    NavigationLink(destination: TipJarSetting()) {
                        SettingsLabelWithIcon(title: "tipJarTitle", icon: "heart", color: .red)
                    }
                    
                    NavigationLink(value: SettingsScreens.about) {
                        SettingsLabelWithIcon(title: "aboutTitle", icon: "info.circle", color: .black)
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
#endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
#endif
