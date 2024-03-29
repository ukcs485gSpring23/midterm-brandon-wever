//
//  Constants.swift
//  OCKSample
//
//  Created by Corey Baker on 11/27/20.
//  Copyright © 2020 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKit
import CareKitStore
import ParseSwift

/**
 Set to **true** to sync with ParseServer, *false** to sync with iOS/watchOS.
 */
let isSyncingWithCloud = true
/**
 Set to **true** to use WCSession to notify watchOS about updates, **false** to not notify.
 A change in watchOS 9 removes the ability to use Websockets on real Apple Watches,
 preventing auto updates from the Parse Server. See the link for
 details: https://developer.apple.com/forums/thread/715024
 */
let isSendingPushUpdatesToWatch = true

enum AppError: Error {
    case couldntCast
    case couldntBeUnwrapped
    case valueNotFoundInUserInfo
    case remoteClockIDNotAvailable
    case emptyTaskEvents
    case invalidIndexPath(_ indexPath: IndexPath)
    case noOutcomeValueForEvent(_ event: OCKAnyEvent, index: Int)
    case cannotMakeOutcomeFor(_ event: OCKAnyEvent)
    case parseError(_ error: ParseError)
    case error(_ error: Error)
    case errorString(_ string: String)
}

extension AppError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .couldntCast:
            return NSLocalizedString("OCKSampleError: Could not cast to required type.",
                                     comment: "Casting error")
        case .couldntBeUnwrapped:
            return NSLocalizedString("OCKSampleError: Could not unwrap a required type.",
                                     comment: "Unwrapping error")
        case .valueNotFoundInUserInfo:
            return NSLocalizedString("OCKSampleError: Could not find the required value in userInfo.",
                                     comment: "Value not found error")
        case .remoteClockIDNotAvailable:
            return NSLocalizedString("OCKSampleError: Could not get remote clock ID.",
                                     comment: "Value not available error")
        case .emptyTaskEvents: return "Task events is empty"
        case let .noOutcomeValueForEvent(event, index): return "Event has no outcome value at index \(index): \(event)"
        case .invalidIndexPath(let indexPath): return "Invalid index path \(indexPath)"
        case .cannotMakeOutcomeFor(let event): return "Cannot make outcome for event: \(event)"
        case .parseError(let error): return "\(error)"
        case .error(let error): return "\(error)"
        case .errorString(let string): return string
        }
    }
}

enum Constants {
    static let parseConfigFileName = "ParseCareKit"
    static let iOSParseCareStoreName = "iOSParseStore"
    static let iOSLocalCareStoreName = "iOSLocalStore"
    static let watchOSParseCareStoreName = "watchOSParseStore"
    static let watchOSLocalCareStoreName = "watchOSLocalStore"
    static let noCareStoreName = "none"
    static let parseUserSessionTokenKey = "requestParseSessionToken"
    static let requestSync = "requestSync"
    static let progressUpdate = "progressUpdate"
    static let finishedAskingForPermission = "finishedAskingForPermission"
    static let shouldRefreshView = "shouldRefreshView"
    static let userLoggedIn = "userLoggedIn"
    static let storeInitialized = "storeInitialized"
    static let userTypeKey = "userType"
    static let card = "card"
    static let survey = "survey"
}

enum MainViewPath {
    case tabs
}

enum CareKitCard: String, CaseIterable, Identifiable {
    var id: Self { self }
    case button = "Button"
    case checklist = "Checklist"
    case featured = "Featured"
    case grid = "Grid"
    case instruction = "Instruction"
    case labeledValue = "Labeled Value"
    case link = "Link"
    case numericProgress = "Numeric Progress"
    case simple = "Simple"
    case survey = "Survey"
    case customWeight = "CustomWeight"
    case note = "Note"
}

enum SchedulePossibilities: String, CaseIterable, Identifiable {
    var id: Self { self }
    case everyDay = "Every Day"
    case everyOtherDay = "Every Other Day"
    case onceAWeekMonday = "Once a Week on Monday"
    case onceAWeekTuesday = "Once a Week on Tuesday"
    case onceAWeekWednesday = "Once a Week on Wednesday"
    case onceAWeekThursday = "Once a Week on Thursday"
    case onceAWeekFriday = "Once a Week on Friday"
    case onceAWeekSaturday = "Once a Week on Saturday"
    case onceAWeekSunday = "Once a Week on Sunday"
}

enum HealthKitPossibilities: String, CaseIterable, Identifiable {
    var id: Self { self }
    case heightTracker = "Height Tracker"
    case weightTracker = "Weight Tracker"
}

enum CarePlanID: String, CaseIterable, Identifiable {
    var id: Self { self }
    case health // Add custom id's for your Care Plans, these are examples
    case checkIn
    case weighIn
    case user
}

enum TaskID {
    static let bodyMass = "body mass"
    static let height = "height"
    static let repetition = "repetition"
    static let chatgtp = "chatGTP"
    static let warmUp = "warm up"
    static let benchPress = "bench press"
    static let core = "core"
    static let completedExercise = "completed exercise"
    static let weighInSurvey = "weigh in survey"
    static let postWorkoutSurvey = "post workout survey"

    static var ordered: [String] {
        // swiftlint:disable:next line_length
        [Self.weighInSurvey, Self.postWorkoutSurvey, Self.bodyMass, Self.height, Self.repetition, Self.core, Self.benchPress, Self.warmUp, Self.completedExercise]
    }
}

enum UserType: String, Codable {
    case patient                           = "Patient"
    case none                              = "None"

    // Return all types as an array, make sure to maintain order above
    func allTypesAsArray() -> [String] {
        return [UserType.patient.rawValue,
                UserType.none.rawValue]
    }
}

enum InstallationChannel: String {
    case global
}
