//
//  UIDevice-Extension.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 24/03/22.
//

import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
