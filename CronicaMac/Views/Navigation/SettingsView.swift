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
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

private struct GeneralSettingsView: View {
    @State private var animateEasterEgg = false
    @State private var updatingItems = false
    @State private var showFeedbackAlert = false
    @State private var feedback: String = ""
    @State private var feedbackSent = false
    @AppStorage("disableTelemetry") private var disableTelemetry = false
    var body: some View {
        Form {
            Section {
                Button(action: {
                    updateItems()
                }, label: {
                    if updatingItems {
                        Text("Updating, please wait.")
                    } else {
                        Text("Update Items")
                    }
                })
                .buttonStyle(.link)
            } header: {
                Label("Sync", systemImage: "arrow.2.circlepath")
            }
            
            Section {
                Toggle("Disable Telemetry", isOn: $disableTelemetry)
                Button("Privacy Policy") {
                    NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                }
                .buttonStyle(.link)
                Button {
                    
                } label: {
                    Label("Send Email", systemImage: "envelope.open")
                }
                .buttonStyle(.link)

                Button("Follow Developer on Twitter") {
                    NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
                }
                .buttonStyle(.link)
            } header: {
                Text("Privacy")
            } footer: {
                Text("privacyfooter")
                    .padding(.bottom)
            }
            
            Section {
                Button( action: {
                    showFeedbackAlert = true
                }, label: {
                    Label("Send feedback", systemImage: "envelope")
                })
                .buttonStyle(.link)
                .alert("Send Feedback", isPresented: $showFeedbackAlert, actions: {
                    TextField("Feedback", text: $feedback)
                    Button("Send") {
                        sendFeedback()
                    }
                    Button("Cancel", role: .cancel) {
                        cancelFeedback()
                    }
                }, message: {
                    Text("Send your suggestions to help improve Cronica.")
                })
                .disabled(disableTelemetry)
            } header: {
                Label("Support", systemImage: "questionmark.circle")
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
                    .font(animateEasterEgg ? .title3 : .caption)
                    .foregroundColor(animateEasterEgg ? .green : nil)
                    .animation(.easeInOut, value: animateEasterEgg)
            }
        }
        .formStyle(.grouped)
    }
    
    private func sendFeedback() {
        if !feedback.isEmpty {
            withAnimation { feedbackSent.toggle() }
            TelemetryErrorManager.shared.handleErrorMessage(feedback, for: "sendFeedback")
            feedback = ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation {
                    feedbackSent = false
                }
            }
        }
    }
    
    private func cancelFeedback() {
        feedback = ""
    }
    
    private func updateItems() {
        Task {
            let background = BackgroundManager()
            withAnimation {
                self.updatingItems.toggle()
            }
            await background.handleAppRefreshContent()
            withAnimation {
                self.updatingItems.toggle()
            }
        }
    }
}

