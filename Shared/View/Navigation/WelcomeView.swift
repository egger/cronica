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
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Spacer()
                    Image("Icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100, alignment: .center)
                        .padding()
                    Spacer()
                }
                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        VStack {
                            Text("Welcome to")
                                .fontWeight(.black)
                                .font(.system(size: 34))
                            Text(" Cronica")
                                .fontWeight(.black)
                                .font(.system(size: 34))
                        }
                        .padding(.horizontal)
                        Spacer()
                    }
                }
                InformationContainerView()
                HStack {
                    Spacer()
                    VStack {
                        Button {
                            withAnimation {
                                displayOnboard.toggle()
                            }
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.blue.gradient)
                        .controlSize(.large)
                        .padding()
                        Button("Privacy Policy") {
                            showPolicy.toggle()
                        }
                        .padding([.horizontal, .bottom])
                    }
                    .padding()
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $showPolicy) {
                SFSafariViewWrapper(url: URL(string: "https://alexandremadeira.dev/cronica/privacy")!)
            }
        }
        .interactiveDismissDisabled(true)
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
            InformationDetailView(title: "Your Watchlist", subTitle: "Add everything you want, the Watchlist automatically organizes it for you.", imageName: "film.circle.fill")
            
            InformationDetailView(title: "Discover what's next", subTitle: "The Discover will help you find your next favorite title.", imageName: "magnifyingglass.circle.fill")
            
            InformationDetailView(title: "Never miss out", subTitle: "Get notifications about the newest releases.", imageName: "bell.circle.fill")
        }
        .padding(.horizontal)
    }
}

private struct InformationDetailView: View {
    var title: String
    var subTitle: String
    var imageName: String
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .padding(.leading)
                .accessibility(hidden: true)
            
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
            
            Spacer()
        }
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 2.5)
        .padding(.top)
    }
}

