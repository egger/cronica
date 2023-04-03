//
//  HapticManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/01/23.
//

import SwiftUI

struct HapticManager {
    static var shared = HapticManager()
    
    func successHaptic() {
#if os(iOS)
        if SettingsStore.shared.hapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
#endif
    }
}
