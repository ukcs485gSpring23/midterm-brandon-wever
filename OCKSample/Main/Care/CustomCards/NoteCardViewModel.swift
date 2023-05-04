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

class NoteCardViewModel: CardViewModel {

    var valueAsString: String {
        get {
            guard let stringValue = value?.stringValue else {
                return ""
            }
            return stringValue
        }
        set {
            value = OCKOutcomeValue(newValue)
        }
    }
}
