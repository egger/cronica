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
                    .shadow(radius: 6)
                    .padding()
                    Spacer()
                }
                .padding()
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
                .padding(.leading)
                .accessibility(hidden: true)
            
            VStack(alignment: .leading) {
                Text(NSLocalizedString(title, comment: ""))
                    .font(.headline)
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
        .background(.thinMaterial)
        .cornerRadius(6)
        .shadow(radius: 2)
        .padding([.top, .horizontal])
    }
}

