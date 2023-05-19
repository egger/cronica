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
    @Binding var showSettings: Bool
    @Environment(\.requestReview) var requestReview
    
    @StateObject private var settings = SettingsStore.shared
    static let tag: Screens? = .settings
    @State private var showPolicy = false
#if os(iOS)
    @SceneStorage("selectedView") private var selectedView: SettingsScreens?
#else
    @SceneStorage("selectedView") private var selectedView: SettingsScreens = .behavior
#endif
#endif
    var body: some View {
#if os(iOS)
        details
#elseif os(macOS)
        macOSSettings
#endif
    }
    
    private var privacy: some View {
        Section {
#if os(iOS) || os(macOS)
            Button("settingsPrivacyPolicy") {
#if os(macOS)
                NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
#else
                showPolicy.toggle()
#endif
            }
#if os(iOS)
            .fullScreenCover(isPresented: $showPolicy) {
                SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
            }
#elseif os(macOS)
            .buttonStyle(.link)
#endif
#endif
        } header: {
#if os(macOS) || os(tvOS)
            Label("Privacy", systemImage: "hand.raised")
#endif
        } footer: {
#if os(tvOS)
            Text("privacyFooterTV")
                .padding(.bottom)
#endif
        }
    }
    
    
#if os(iOS)
    private var details: some View {
        NavigationStack {
            Form {
                if settings.displayDeveloperSettings {
                    NavigationLink(value: SettingsScreens.developer) {
                        SettingsLabelWithIcon(title: "Developer Options", icon: "hammer", color: .purple)
                    }
                }
                
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
                }
                
                // Privacy and support section
                Section {
                    privacy
                    NavigationLink(destination: FeedbackSettingsView()) {
                        SettingsLabelWithIcon(title: "settingsFeedbackTitle", icon: "envelope.open", color: .teal)
                    }
                }
                
                
                Button {
                    requestReview()
                } label: {
                    Text("settingsReviewCronica")
                }
                ShareLink(item: URL(string: "https://apple.co/3TV9SLP")!)
                    .labelStyle(.titleOnly)
                
                // About section
                Section {
                    NavigationLink(destination: TipJarSetting()) {
                        SettingsLabelWithIcon(title: "tipJarTitle", icon: "heart", color: .red)
                    }
                    
                    NavigationLink(value: SettingsScreens.about) {
                        SettingsLabelWithIcon(title: "aboutTitle", icon: "info.circle", color: .teal)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsScreens.self) { settings in
                switch settings {
                case .about: AboutSettings()
                case .appearance: AppearanceSetting()
                case .behavior: BehaviorSetting()
                case .developer: DeveloperView()
                case .feedback: FeedbackSettingsView()
                case .notifications: NotificationsSettingsView()
                case .sync: SyncSetting()
                case .tipJar: TipJarSetting()
                default: BehaviorSetting()
                }
            }
        }
    }
#endif
    
#if os(macOS)
    private var macOSSettings: some View {
        TabView {
            BehaviorSetting()
                .tabItem {
                    Label("settingsBehaviorTitle", systemImage: "cursorarrow.click")
                }
            AppearanceSetting()
                .tabItem {
                    Label("settingsAppearanceTitle", systemImage: "moon.stars")
                }
            SyncSetting()
                .tabItem {
                    Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
                }
            
            FeedbackSettingsView()
                .tabItem {
                    Label("Feedback", systemImage: "envelope.open.fill")
                }
            
            Form {
                //PrivacySupportSetting()
            }
            .formStyle(.grouped)
            .tabItem {
                Label("Privacy", systemImage: "hand.raised.fill")
            }
            
            #warning("check count api to reenable this feature")
//            Form {
//                FeatureRoadmap()
//            }
//            .formStyle(.grouped)
//            .tabItem {
//                Label("featureRoadmap", systemImage: "map")
//            }
            
            TipJarSetting()
                .tabItem {
                    Label("tipJar", systemImage: "heart")
                }
            
            AcknowledgementsSettings()
                .tabItem {
                    Label("acknowledgmentsTitle", systemImage: "doc")
                }
        }
        .frame(minWidth: 720, idealWidth: 720, minHeight: 320, idealHeight: 320)
        .tabViewStyle(.automatic)
    }
#endif
}

struct SettingsView_Previews: PreviewProvider {
    @State private static var dismiss = false
    static var previews: some View {
#if os(iOS)
        SettingsView(showSettings: $dismiss)
#else
        SettingsView()
#endif
    }
}
