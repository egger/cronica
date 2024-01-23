//
//  SettingsView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

/// Renders the Settings UI for each OS, support iOS, macOS, and tvOS.
struct SettingsView: View {
#if os(iOS) || os(visionOS)
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
#if os(iOS) || os(visionOS)
        Form {
            Section {
                NavigationLink(value: SettingsScreens.behavior) {
                    settingsLabel(title: NSLocalizedString("Behavior", comment: ""),
                                  icon: "hand.tap", color: .gray)
                }
                NavigationLink(value: SettingsScreens.appearance) {
                    settingsLabel(title: NSLocalizedString("Appearance", comment: ""),
                                  icon: "paintbrush", color: .blue)
                }
                NavigationLink(value: SettingsScreens.sync) {
                    settingsLabel(title: NSLocalizedString("Sync", comment: ""),
                                  icon: "arrow.triangle.2.circlepath", color: .green)
                }
                NavigationLink(value: SettingsScreens.notifications) {
                    settingsLabel(title: NSLocalizedString("Notification", comment: ""),
                                  icon: "bell", color: .red)
                }
                NavigationLink(value: SettingsScreens.region) {
                    settingsLabel(title: NSLocalizedString("Region", comment: ""),
                                  icon: "globe", color: .purple)
                }
            }
            
            Section {
                NavigationLink(value: SettingsScreens.feedback) {
                    settingsLabel(title: NSLocalizedString("Feedback", comment: ""),
                                  icon: "envelope.fill", color: AppThemeColors.steel.color)
                }
                Button {
                    showPolicy.toggle()
                } label: {
                    settingsLabel(title: NSLocalizedString("Privacy Policy", comment: ""),
                                  icon: "hand.raised", color: .indigo)
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
                    settingsLabel(title: NSLocalizedString("What's New", comment: ""),
                                  icon: "sparkles", color: .yellow)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showWhatsNew) {
                    ChangelogView(showChangelog: $showWhatsNew)
                        .appTint()
                        .appTheme()
                }
                NavigationLink(value: SettingsScreens.tipJar) {
                    settingsLabel(title: NSLocalizedString("Tip Jar", comment: ""),
                                  icon: "heart", color: .red)
                }
                
                NavigationLink(value: SettingsScreens.about) {
                    settingsLabel(title: NSLocalizedString("About", comment: ""),
                                  icon: "info.circle", color: .black)
                }
            }
        }
        .navigationTitle("Settings")
#elseif os(macOS)
        TabView {
            BehaviorSetting()
                .tabItem { Label("Behavior", systemImage: "cursorarrow.click") }
            
            AppearanceSetting()
                .tabItem { Label("Appearance", systemImage: "moon.stars") }
            
            SyncSetting()
                .tabItem { Label("Sync", systemImage: "arrow.triangle.2.circlepath") }
            
            NotificationsSettingsView()
                .tabItem { Label("Notification", systemImage: "bell") }
            
            RegionContentSettings()
                .tabItem { Label("Region", systemImage: "globe")  }
            
            TipJarSetting()
                .tabItem { Label("Tip Jar", systemImage: "heart") }
        }
        .frame(minWidth: 420, idealWidth: 500, minHeight: 320, idealHeight: 320)
        .tabViewStyle(.automatic)
#elseif os(tvOS)
        NavigationStack {
            Form {
                Section {
                    NavigationLink("Behavior", destination: BehaviorSetting())
                    NavigationLink("Appearance", destination: AppearanceSetting())
                }
                
                Section {
                    NavigationLink("Sync", destination: SyncSetting())
                }
                
                Section {
                    NavigationLink("Tip Jar", destination: TipJarSetting())
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

#Preview {
    SettingsView()
}
