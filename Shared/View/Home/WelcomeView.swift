//
//  WelcomeView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/03/22.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("showOnboarding") var displayOnboard = true
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
                HStack {
                    Spacer()
                    Image("Icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120, alignment: .center)
                        .shadow(color: .black.opacity(0.8), radius: 2.5)
                        .padding()
                    Spacer()
                }
                .padding(.top)
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
                Spacer(minLength: 30)
                HStack {
                    Spacer()
                    NavigationLink(destination: ContentView()) {
                        Button {
                            withAnimation {
                                displayOnboard.toggle()
                            }
                        } label: {
                            Text("Continue")
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .padding()
                    }
                    Spacer()
                }
                .padding()
            }
        }
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
            InformationDetailView(title: "Find", subTitle: "Search for upcoming movies and tv shows.", imageName: "magnifyingglass.circle.fill")
            
            InformationDetailView(title: "Never miss out", subTitle: "Get notifications about the newest releases.", imageName: "bell.circle.fill")
            
            InformationDetailView(title: "Organize", subTitle: "Keep everything organized inside the Watchlist.", imageName: "folder.circle.fill")
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
                .padding()
                .accessibility(hidden: true)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                
                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

