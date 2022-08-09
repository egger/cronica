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
#if os(watchOS)
#else
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred(intensity: 1.0)
#endif
    }
    
    func lightHaptic() {
#if os(watchOS)
#else
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 1.0)
#endif
    }
    
    func mediumHaptic() {
#if os(watchOS)
#else
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred(intensity: 1.0)
#endif
    }
    
    func heavyHaptic() {
#if os(watchOS)
#else
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
#endif
    }
    
    func rigidHaptic() {
#if os(watchOS)
#else
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred(intensity: 1.0)
#endif
    }
}
