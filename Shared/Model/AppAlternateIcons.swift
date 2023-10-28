//
//  AppAlternateIcons.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 05/04/23.
//
#if os(iOS)
import Foundation
import UIKit

enum Icon: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case primary = "AppIcon"
    case ticket = "AppIcon2"
    
    var iconName: String? {
        switch self {
        case .primary: return nil
        default: return rawValue
        }
    }
    
    var description: String {
        switch self {
        case .primary:
            return NSLocalizedString("Ticket", comment: "")
        case .ticket:
            return NSLocalizedString("Classical", comment: "")
        }
    }
    
    var preview: UIImage {
        switch self {
        case .primary:
            return UIImage(named: Icon.primary.rawValue) ?? UIImage()
        case .ticket:
            return UIImage(named: Icon.ticket.rawValue) ?? UIImage()
        }
    }
}

class IconModel: ObservableObject {
    @Published private(set) var selectedAppIcon: Icon = .primary
    
    init() {
        if let iconName = UIApplication.shared.alternateIconName, let appIcon = Icon(rawValue: iconName) {
            selectedAppIcon = appIcon
        } else {
            selectedAppIcon = .primary
        }
    }
    
    func updateAppIcon(to icon: Icon) {
        selectedAppIcon = icon
        Task { @MainActor in
            guard UIApplication.shared.alternateIconName != icon.iconName else { return }
            try? await UIApplication.shared.setAlternateIconName(icon.iconName)
        }
    }
}
#endif
