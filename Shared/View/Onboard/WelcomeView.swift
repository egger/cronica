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

private struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            informationItem(
                title: "Your Watchlist",
                subtitle: "Add everything you want, the Watchlist automatically organizes it for you.",
                imageName: "rectangle.stack.fill",
                imageTint: .purple
            )
            
            informationItem(
                title: "Always Synced",
                subtitle: "Your Watchlist is always in sync with your Apple Watch, iPad, Mac, and Apple TV.",
                imageName: "icloud.fill"
            )
            
            informationItem(
                title: "Track your episodes",
                subtitle: "Keep track of every episode you've watched.",
                imageName: "rectangle.fill.badge.checkmark",
                imageTint: .green
            )
            
            informationItem(
                title: "Never miss out",
                subtitle: "Get notifications about the newest releases.",
                imageName: "bell.fill",
                imageTint: .orange
            )
            
        }
    }
    
    private func informationItem(
        title: String,
        subtitle: String,
        imageName: String,
        imageTint: Color = .blue
    ) -> some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .frame(width: 60)
                .accessibility(hidden: true)
                .foregroundColor(imageTint)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString(title, comment: ""))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .fontDesign(.rounded)
                
                Text(NSLocalizedString(subtitle, comment: ""))
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fontDesign(.rounded)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 6)
            .padding([.top, .bottom], 8)
        }
        .padding(.top)
    }
}

#Preview {
    WelcomeView()
}
