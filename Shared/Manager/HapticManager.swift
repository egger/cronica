//
//  HapticManager.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 05/04/22.
//

import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    
    func softHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 1.0)
    }
    
    func mediumHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 1.0)
    }
}
