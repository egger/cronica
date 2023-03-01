//
//  SettingsView.swift
//  CronicaMac
//
//  Created by Alexandre Madeira on 02/11/22.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
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
                PrivacySupportSetting()
            }
            .formStyle(.grouped)
            .tabItem {
                Label("Privacy", systemImage: "hand.raised.fill")
            }
            
            Form {
                FeatureRoadmap()
            }
            .formStyle(.grouped)
            .tabItem {
                Label("featureRoadmap", systemImage: "map")
            }
            
            AcknowledgementsSettings()
                .tabItem {
                    Label("acknowledgmentsTitle", systemImage: "doc")
                }
        }
        .frame(width: 640, height: 320)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
