//
//  OverlayView.swift
//  Story
//
//  Created by Alexandre Madeira on 29/01/22.
//

import SwiftUI

protocol EmptyData {
    var isEmpty: Bool { get }
}

struct OverlayView<T: EmptyData>: View {
    let phase: DataFetchPhase<T>
    let retry: () -> ()
    let title: String
    var body: some View {
        VStack {
            switch phase {
            case .empty:
                ProgressView(title)
                    .padding()
            case .success(let value) where value.isEmpty:
                Text("Something went wrong, try again later.")
                    .font(.title)
                    .padding()
            case .failure(let error):
                RetryView(text: error.localizedDescription, retryAction: retry)
            default:
                EmptyView()
            }
        }
    }
}

extension Array: EmptyData {}
extension Optional: EmptyData {
    
    var isEmpty: Bool {
        if case .none = self {
            return true
        }
        return false
    }
    
}

struct RetryView: View {
    
    let text: String
    let retryAction: () -> ()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(text)
                .font(.callout)
                .multilineTextAlignment(.center)
            
            Button(action: retryAction) {
                Text("Try Again")
            }
        }
    }
}

//struct OverlayView_Previews: PreviewProvider {
//    static var previews: some View {
//        OverlayView()
//    }
//}
