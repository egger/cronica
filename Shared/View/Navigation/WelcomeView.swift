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

private struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
            InformationContainerItem(title: "Your Watchlist", subTitle: "Add everything you want, the Watchlist automatically organizes it for you.", imageName: "film.stack.fill", imageTint: .gray)
            
            InformationContainerItem(title: "Discover what's next", subTitle: "The Discover will help you find your next favorite title.", imageName: "square.grid.3x3.topleft.filled", imageTint: .teal)
            
            InformationContainerItem(title: "Never miss out", subTitle: "Get notifications about the newest releases.", imageName: "bell.fill", imageTint: .orange)
            
            InformationContainerItem(title: "Track your episodes",
                                     subTitle: "Keep track of every episode you've watched.",
                                     imageName: "rectangle.fill.badge.checkmark",
                                     imageTint: .green)
            
            InformationContainerItem(title: "Always Synced",
                                     subTitle: "Your Watchlist is always in sync with your Apple Watch, iPad, Mac, and Apple TV.",
                                     imageName: "icloud.fill")
        }
    }
}

private struct InformationContainerItem: View {
    var title: String
    var subTitle: String
    var imageName: String
    var imageTint: Color = .blue
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .frame(width: 60)
                .accessibility(hidden: true)
                .foregroundColor(imageTint)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString(title, comment: ""))
                    .font(.title3)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                
                Text(NSLocalizedString(subTitle, comment: ""))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.leading, 6)
            .padding([.top, .bottom], 8)
        }
        .padding(.top)
    }
}
