//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI
#warning("test out settings")
struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.requestReview) var requestReview
    @AppStorage("displayDeveloperSettings") private var displayDeveloperSettings = false
    @State private var animateEasterEgg = false
    var body: some View {
        Form {
            developer
            general
            PrivacySupportSetting()
            Button {
                requestReview()
            } label: {
                Label("settingsReviewCronica", systemImage: "star.fill")
            }
            ShareLink(item: URL(string: "https://apple.co/3TV9SLP")!)
            about
        }
    }
    
    @ViewBuilder
    private var developer: some View {
        if displayDeveloperSettings {
            NavigationLink(destination: DeveloperView()) {
                Label("settingsDeveloperOptions", systemImage: "hammer")
            }
        } else {
            EmptyView()
        }
    }
    
    private var general: some View {
        Section {
            NavigationLink(destination: BehaviorSetting()) {
                Label("settingsBehaviorTitle", systemImage: "hand.tap")
            }
            NavigationLink(destination: AppearanceSetting()) {
                Label("settingsAppearanceTitle", systemImage: "moon.stars")
            }
            NavigationLink(destination: SyncSetting()) {
                Label("settingsSyncTitle", systemImage: "arrow.triangle.2.circlepath")
            }
        } header: {
            Label("settingsGeneralTitle", systemImage: "wrench.adjustable")
        }
    }
    
    private var about: some View {
        Section {
            NavigationLink(destination: TipJarSetting()) {
                Label("tipJarTitle", systemImage: "heart")
            }
            NavigationLink(destination: AcknowledgementsSettings()) {
                Label("acknowledgmentsTitle", systemImage: "doc")
            }
            Button {
                
            } label: {
                Text("developerWebsite")
            }
            CenterHorizontalView {
                Text("Made in Brazil 🇧🇷")
                    .onTapGesture {
                        Task {
                            withAnimation {
                                self.animateEasterEgg.toggle()
                            }
                            try? await Task.sleep(nanoseconds: 1_500_000_000)
                            withAnimation {
                                self.animateEasterEgg.toggle()
                            }
                        }
                    }
                    .onLongPressGesture(perform: {
                        displayDeveloperSettings.toggle()
                    })
                    .font(animateEasterEgg ? .title3 : .caption)
                    .foregroundColor(animateEasterEgg ? .green : nil)
                    .animation(.easeInOut, value: animateEasterEgg)
            }
        } header: {
            Label("About", systemImage: "info.circle")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
