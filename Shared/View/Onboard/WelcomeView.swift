//
//  WelcomeView.swift
//  Story (iOS)
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
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(radius: 2)
                        .padding(.leading)
                    VStack(alignment: .leading) {
                        Text("Cronica")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Be reminded of upcoming Movies & TV Shows.")
                            .foregroundColor(.secondary)
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
            CenterHorizontalView {
                VStack {
                    Button {
                        withAnimation {
                            displayOnboard.toggle()
                        }
                    } label: {
                        Text("Continue")
                            .frame(width: 200)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.blue.gradient)
#if os(iOS) || os(macOS)
                    .controlSize(.large)
#endif
                    .shadow(radius: 5)
                    .padding()
                    Button("Privacy Policy") {
#if os(macOS)
                        NSWorkspace.shared.open(URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
#else
                        showPolicy.toggle()
#endif
                    }
                    .padding([.horizontal, .bottom])
#if os(macOS)
                    .buttonStyle(.link)
#endif
                }
                .padding()
            }
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
