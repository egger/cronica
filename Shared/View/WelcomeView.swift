//
//  WelcomeView.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 18/03/22.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
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
                    Button(action: {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }) {
                        Text("Continue")
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .padding(.horizontal)
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
            
            InformationDetailView(title: "Organize", subTitle: "Keep every item organized inside the Watchlist.", imageName: "folder.circle.fill")
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
                .foregroundColor(.blue)
//                .foregroundColor(Color(red: 0.929, green: 0.706, blue: 0.698, opacity: 1.000))
                .padding()
                .accessibility(hidden: true)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                //.padding(.bottom, 2)
                
                Text(subTitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

