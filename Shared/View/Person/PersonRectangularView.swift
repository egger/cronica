//
//  CreditsProfileImageView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

struct PersonRectangularView: View {
    let name: String
    let characterOrJob: String?
    let imageUrl: URL?
    var body: some View {
        ZStack {
            CreditImageView(url: imageUrl)
            CreditInfoView(name: name, characterOrJob: characterOrJob)
        }
        .frame(width: DrawingConstants.profileWidth,
               height: DrawingConstants.profileHeight)
        .clipShape(RoundedRectangle(cornerRadius: DrawingConstants.profileRadius, style: .continuous))
        .padding(2)
        .shadow(color: .black.opacity(DrawingConstants.shadowOpacity),
                radius: DrawingConstants.shadowRadius)
    }
}

//struct CreditsProfileImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonRectangularView(name: Credits.previewCast.name , characterOrJob: Credits.previewCast.role, imageUrl: Credits.previewCast.image)
//    }
//}



private struct CreditImageView: View {
    let url: URL?
    var body: some View {
        ZStack {
            if url == nil {
                ZStack {
                    Rectangle()
                        .fill(.gray)
                    Image(systemName: "person")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                
            } else {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .overlay(.ultraThinMaterial)
                    Rectangle()
                        .fill(.black.opacity(0.5))
                        .overlay(.ultraThinMaterial)
                    image
                        .resizable()
                        .scaledToFill()
                        .mask {
                            LinearGradient(gradient: Gradient(colors:
                                                                [.black,
                                                                 .black.opacity(0)]),
                                           startPoint: .center,
                                           endPoint: .bottom)
                        }
                } placeholder: {
                    Rectangle()
                        .fill(.thickMaterial)
                        .redacted(reason: .placeholder)
                }
            }
        }
    }
}

private struct CreditInfoView: View {
    let name: String
    let characterOrJob: String?
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(name)
                    .foregroundColor(.white)
                    .lineLimit(DrawingConstants.lineLimit)
                    .padding(.leading, 6)
                    .padding(.bottom, 1)
                Spacer()
            }
            if characterOrJob != nil && !characterOrJob.isEmpty {
                HStack {
                    Text(characterOrJob!)
                        .foregroundColor(.white.opacity(0.8))
                        .font(.caption)
                        .lineLimit(1)
                        .padding(.leading, 6)
                        .padding(.bottom)
                    Spacer()
                }
            }
        }
    }
}

private struct DrawingConstants {
    static let profileWidth: CGFloat = 140
    static let profileHeight: CGFloat = 200
    static let shadowRadius: CGFloat = 5
    static let shadowOpacity: Double = 0.5
    static let profileRadius: CGFloat = 12
    static let lineLimit: Int = 1
}
