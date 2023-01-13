//
//  HapticManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 12/01/23.
//

import SwiftUI

struct HapticManager {
    static var shared = HapticManager()
    @AppStorage("enableHapticFeedback") private var hapticFeedback = true
    
    func successHaptic() {
#if os(iOS)
        if hapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
#endif
    }
}
