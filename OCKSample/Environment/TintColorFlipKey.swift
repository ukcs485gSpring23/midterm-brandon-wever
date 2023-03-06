//
//  TintColorFlipKey.swift
//  OCKSample
//
//  Created by Corey Baker on 9/26/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import SwiftUI

struct TintColorFlipKey: EnvironmentKey {
    static var defaultValue: UIColor {
        #if os(iOS)
        return UIColor { $0.userInterfaceStyle == .light ?  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1) }
        #else
        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        #endif
    }
}

extension EnvironmentValues {
    var tintColorFlip: UIColor {
        self[TintColorFlipKey.self]
    }
}
