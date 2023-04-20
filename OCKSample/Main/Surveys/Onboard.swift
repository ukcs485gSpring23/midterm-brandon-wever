//
//  Onboarding.swift
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

struct Onboard: Surveyable {
    static var surveyType: Survey {
        Survey.onboard
    }
}

#if canImport(ResearchKit)
extension Onboard {
    /*
     TODOxx: Modify the onboarding so it properly represents the
     usecase of your application. Changes should be made to
     each of the steps in this type method. For example, you
     should change: title, detailText, image, and imageContentMode,
     and learnMoreItem.
     */
    func createSurvey() -> ORKTask {
        // The Welcome Instruction step.
        let welcomeInstructionStep = ORKInstructionStep(
            identifier: "\(identifier()).welcome"
        )

        welcomeInstructionStep.title = "Welcome to Alpine Fitness!"
        // swiftlint:disable:next line_length
        welcomeInstructionStep.detailText = "Thank you for starting your health journey with us. Continue by hitting next to complete the onboarding process."
        welcomeInstructionStep.image = UIImage(named: "snowMountain.jpg")
        welcomeInstructionStep.imageContentMode = .top

        // The Informed Consent Instruction step.
        let studyOverviewInstructionStep = ORKInstructionStep(
            identifier: "\(identifier()).overview"
        )

        studyOverviewInstructionStep.title = "Before You Join"
        studyOverviewInstructionStep.iconImage = UIImage(systemName: "checkmark.seal.fill")

        let heartBodyLearnMoreInstructionStep = ORKLearnMoreInstructionStep(identifier: "heartBodyInstructionStep")
        // swiftlint:disable:next line_length
        heartBodyLearnMoreInstructionStep.text = "Enable health access permissions to use our app to it's full potential."
        let defaultLearnMoreItem = ORKLearnMoreItem.init(text: "Learn More",
                                                         learnMoreInstructionStep: heartBodyLearnMoreInstructionStep)

        let heartBodyItem = ORKBodyItem(
            text: "Our app will ask you to share some of your health data.",
            detailText: nil,
            image: UIImage(systemName: "heart.fill"),
            learnMoreItem: defaultLearnMoreItem,
            bodyItemStyle: .image
        )

        let completeTasksBodyItem = ORKBodyItem(
            text: "You will be asked to complete various tasks when using our app.",
            detailText: nil,
            image: UIImage(systemName: "checkmark.circle.fill"),
            learnMoreItem: defaultLearnMoreItem,
            bodyItemStyle: .image
        )

        let signatureBodyItem = ORKBodyItem(
            text: "Before joining, we will ask you to sign an informed consent document.",
            detailText: nil,
            image: UIImage(systemName: "signature"),
            learnMoreItem: defaultLearnMoreItem,
            bodyItemStyle: .image
        )

        let secureDataBodyItem = ORKBodyItem(
            text: "Your data is kept private and secure.",
            detailText: nil,
            image: UIImage(systemName: "lock.fill"),
            learnMoreItem: defaultLearnMoreItem,
            bodyItemStyle: .image
        )

        studyOverviewInstructionStep.bodyItems = [
            heartBodyItem,
            completeTasksBodyItem,
            signatureBodyItem,
            secureDataBodyItem
        ]

        // The Signature step (using WebView).
        let webViewStep = ORKWebViewStep(
            identifier: "\(identifier()).signatureCapture",
            html: informedConsentHTML
        )

        webViewStep.showSignatureAfterContent = true

        // The Request Permissions step.
        // TODOxx: Set these to HealthKit info you want to display
        // by default.
        let healthKitTypesToWrite: Set<HKSampleType> = [
            .quantityType(forIdentifier: .bodyMassIndex)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .workoutType()
        ]

        let healthKitTypesToRead: Set<HKObjectType> = [
            .characteristicType(forIdentifier: .dateOfBirth)!,
            .workoutType(),
            .quantityType(forIdentifier: .appleStandTime)!,
            .quantityType(forIdentifier: .appleExerciseTime)!,
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .bodyMassIndex)!
        ]

        let healthKitPermissionType = ORKHealthKitPermissionType(
            sampleTypesToWrite: healthKitTypesToWrite,
            objectTypesToRead: healthKitTypesToRead
        )

        let notificationsPermissionType = ORKNotificationPermissionType(
            authorizationOptions: [.alert, .badge, .sound]
        )

        let motionPermissionType = ORKMotionActivityPermissionType()

        let requestPermissionsStep = ORKRequestPermissionsStep(
            identifier: "\(identifier()).requestPermissionsStep",
            permissionTypes: [
                healthKitPermissionType,
                notificationsPermissionType,
                motionPermissionType
            ]
        )

        requestPermissionsStep.title = "Health Data Request"
        // swiftlint:disable:next line_length
        requestPermissionsStep.text = "Please review the health data types below and enable sharing to contribute to the study."

        // Completion Step
        let completionStep = ORKCompletionStep(
            identifier: "\(identifier()).completionStep"
        )

        completionStep.title = "Enrollment Complete"
        // swiftlint:disable:next line_length
        completionStep.text = "Thank you for enrolling in this study. Your participation will contribute to meaningful research!"

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [
                welcomeInstructionStep,
                studyOverviewInstructionStep,
                webViewStep,
                requestPermissionsStep,
                completionStep
            ]
        )
        return surveyTask
    }

    func extractAnswers(_ result: ORKTaskResult) -> [CareKitStore.OCKOutcomeValue]? {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Utility.requestHealthKitPermissions()
        }
        return [OCKOutcomeValue(Date())]
    }
}
#endif
