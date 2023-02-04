//
//  SupportEmail.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 22/01/23.
//

//import UIKit
import SwiftUI

struct SupportEmail {
    let toAddress: String = "contact@alexandremadeira.dev"
    let subject: String = "Support Email (Cronica App)"
    let messageHeader: String = "Feedback:"
    var body: String {"""
        \(messageHeader)
    """
    }
    
    func send(openURL: OpenURLAction) {
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        openURL(url) { accepted in
            if !accepted {
                let message = """
                This device does not support email
                \(body)
                """
                CronicaTelemetry.shared.handleMessage(message, for: "SupportEmail.send()")
            }
        }
    }
}
