//
//  SettingsView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/03/22.
//

import SwiftUI

#if os(iOS)
struct SettingsView: View {
    @Binding var showSettings: Bool
    @Environment(\.requestReview) var requestReview
    @State private var animateEasterEgg = false
    @StateObject private var settings = SettingsStore.shared
    var body: some View {
        NavigationStack {
            Form {
                developer
                general
                privacySupport
                Button {
                    requestReview()
                } label: {
                    Text("settingsReviewCronica")
                }
                ShareLink(item: URL(string: "https://apple.co/3TV9SLP")!)
                    .labelStyle(.titleOnly)
                about
            }
            .toolbar {
                Button("Done") { showSettings = false }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .appTheme()
        .appTint()
    }
    
    @ViewBuilder
    private var developer: some View {
#if DEBUG || targetEnvironment(simulator)
        developerButton
#else
        if settings.displayDeveloperSettings {
            developerButton
        } else {
            EmptyView()
        }
#endif
    }
    
    private var developerButton: some View {
        NavigationLink(destination: DeveloperView()) {
            SettingsLabelWithIcon(title: "settingsDeveloperOptions", icon: "hammer", color: .purple)
        }
    }
    
    private var general: some View {
        Section {
            NavigationLink(destination: BehaviorSetting()) {
                SettingsLabelWithIcon(title: "settingsBehaviorTitle", icon: "hand.tap", color: .gray)
            }
            NavigationLink(destination: AppearanceSetting()) {
                SettingsLabelWithIcon(title: "settingsAppearanceTitle", icon: "paintbrush", color: .blue)
            }
            NavigationLink(destination: SyncSetting()) {
                SettingsLabelWithIcon(title: "settingsSyncTitle", icon: "arrow.triangle.2.circlepath", color: .green)
            }
            NavigationLink(destination: NotificationsSettingsView()) {
                SettingsLabelWithIcon(title: "settingsNotificationTitle", icon: "bell", color: .red)
            }
        }
    }
    
    private var privacySupport: some View {
        Section {
            NavigationLink(destination: PrivacySupportSetting()) {
                SettingsLabelWithIcon(title: "Privacy", icon: "hand.raised", color: .blue)
            }
            NavigationLink(destination: FeedbackSettingsView()) {
                SettingsLabelWithIcon(title: "settingsFeedbackTitle", icon: "envelope.open", color: .teal)
            }
            NavigationLink(destination: FeatureRoadmap()) {
                SettingsLabelWithIcon(title: "featureRoadmap", icon: "map", color: .pink)
            }
        }
    }
    
    private var about: some View {
        Section {
            NavigationLink(destination: TipJarSetting()) {
                SettingsLabelWithIcon(title: "tipJarTitle", icon: "heart", color: .red)
            }
            NavigationLink(destination: AcknowledgementsSettings()) {
                SettingsLabelWithIcon(title: "acknowledgmentsTitle", icon: "doc", color: .yellow)
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
                    .onLongPressGesture {
                        withAnimation { settings.displayDeveloperSettings.toggle() }
                    }
                    .font(animateEasterEgg ? .title3 : .caption)
                    .foregroundColor(animateEasterEgg ? .green : nil)
                    .animation(.easeInOut, value: animateEasterEgg)
            }
        }
    }
}


//struct SettingsView_Previews: PreviewProvider {
//    @State private static var dismiss = false
//    static var previews: some View {
//        SettingsView(showSettings: $dismiss)
//    }
//}

private struct SettingsLabelWithIcon: View {
    let title: String
    let icon: String
    let color: Color
    var body: some View {
        HStack {
            ZStack {
                Rectangle()
                    .fill(color.gradient)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                Image(systemName: icon)
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30, alignment: .center)
            .padding(.trailing, 8)
            .accessibilityHidden(true)
            Text(LocalizedStringKey(title))
        }
    }
}
#endif
