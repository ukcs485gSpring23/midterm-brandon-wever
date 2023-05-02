//
//  Survey.swift
//  OCKSample
//
//  Created by Corey Baker on 4/13/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import Foundation
import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

enum Survey: String, CaseIterable, Identifiable {
    var id: Self { self }
    case onboard = "Onboard"
    case checkIn = "Check In"
    case postWorkoutRating = "Post Workout Rating"
    case rangeOfMotion = "Range of Motion"
    case weighIn = "Weigh In"

    func type() -> Surveyable {
        switch self {
        case .onboard:
            return Onboard()
        case .checkIn:
            return CheckIn()
        case .rangeOfMotion:
            return RangeOfMotion()
        case .weighIn:
            return WeighIn()
        case .postWorkoutRating:
            return PostWorkoutRating()
        }
    }
}
