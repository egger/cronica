//
//  WelcomeView.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 18/03/22.
//

import SwiftUI

/// Onboard experience.
struct WelcomeView: View {
    @AppStorage("showOnboarding") var displayOnboard = true
    @State private var showPolicy = false
    var body: some View {
        VStack(alignment: .leading) {
            CenterHorizontalView {
                HStack {
                    Image("Cronica")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .shadow(radius: 5)
                        .padding(.leading)
                    VStack(alignment: .leading) {
                        Text("Cronica")
                            .font(.title)
                            .fontWeight(.bold)
                            .fontDesign(.rounded)
                        Text("Be reminded of upcoming Movies & TV Shows.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontDesign(.rounded)
                            .padding(.trailing)
                    }
                    .padding(.leading, 6)
                }
            }
            .padding([.top, .bottom])
            ScrollView {
                InformationContainerView()
            }
            .padding(.horizontal)
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation {
                        displayOnboard.toggle()
                    }
                } label: {
                    Text("Continue")
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.blue.gradient)
#if os(iOS) || os(macOS)
                .controlSize(.large)
#endif
                .padding([.leading, .vertical])
                Button {
#if os(macOS)
                    NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
#else
                    showPolicy.toggle()
#endif
                } label: {
                    Text("Privacy Policy")
                        .lineLimit(1)
                }
                .padding([.horizontal, .vertical])
#if os(iOS) || os(macOS)
                .controlSize(.large)
#endif
#if os(macOS)
                .buttonStyle(.link)
#else
                .buttonStyle(.bordered)
#endif
                Spacer()
            }
            .padding()
        }
        .interactiveDismissDisabled(true)
#if os(iOS)
        .fullScreenCover(isPresented: $showPolicy) {
            SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
        }
#endif
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
        WelcomeView()
            .preferredColorScheme(.dark)
    }
}
