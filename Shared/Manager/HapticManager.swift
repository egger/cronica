//
//  HapticManager.swift
//  Cronica (iOS)
//
//  Created by Alexandre Madeira on 12/01/23.
//

import SwiftUI

struct HapticManager {
    static var shared = HapticManager()
    private var settings = SettingsStore.shared
    private init() { }
    
    func successHaptic() {
#if os(iOS)
        if settings.hapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
#endif
    }
    
    func selectionHaptic() {
#if os(iOS)
        if settings.hapticFeedback {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
#endif
    }
}
