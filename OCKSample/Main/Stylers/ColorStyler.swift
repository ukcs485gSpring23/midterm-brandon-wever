//
//  ColorStyler.swift
//  OCKSample
//
//  Created by Corey Baker on 10/16/21.
//  Copyright © 2021 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitUI
import UIKit

struct ColorStyler: OCKColorStyler {
    #if os(iOS)
    var label: UIColor {
        FontColorKey.defaultValue
    }
    var tertiaryLabel: UIColor {
        TintColorKey.defaultValue
    }
    var secondaryLabel: UIColor { #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1) }
    var separator: UIColor { #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) }
    var secondaryCustomGroupedBackground: UIColor { #colorLiteral(red: 0.9998105168, green: 0.9952459931, blue: 0.8368335366, alpha: 1) }
    #endif
}
