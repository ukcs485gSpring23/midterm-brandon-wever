//
//  CustomCardViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import CareKit
import CareKitStore
import Foundation

class CustomCardViewModel: CardViewModel {
    /*
     TODOxxx: Place any additional properties needed for your custom Card.
     Be sure to @Published them if they update your view
     */

    let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = ""
        return formatter
    }()

    var valueAsInt: Int {
        get {
            guard let intValue = value?.integerValue else {
                return 0
            }
            return intValue
        }
        set {
            value = OCKOutcomeValue(newValue)
        }
    }
}
