//
//  AppearanceStyle.swift
//  OCKSample
//
//  Created by Brandon Wever on 3/2/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitUI

struct AppearanceStyle: OCKAppearanceStyler {
    var cornerRadius1: CGFloat { 25 }
    var cornerRadius2: CGFloat { 25 }

    var borderWidth1: CGFloat { 5 }
    var borderWidth2: CGFloat { 5 }

    var shadowOpacity1: Float { 0.25 }
}
