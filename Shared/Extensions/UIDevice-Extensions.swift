//
//  UIDevice-Extensions.swift
//  Story (iOS)
//
//  Created by Alexandre Madeira on 09/05/22.
//

import Foundation
import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
