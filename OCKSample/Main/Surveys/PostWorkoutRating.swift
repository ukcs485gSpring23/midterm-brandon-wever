//
//  PostWorkoutRating.swift
//  OCKSample
//
//  Created by Brandon Wever on 5/2/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

struct PostWorkoutRating: Surveyable {
    static var surveyType: Survey {
        Survey.postWorkoutRating
    }

    static var formIdentifier: String {
        "\(Self.identifier()).form"
    }

    static var difficultyItemIdentifier: String {
        "\(Self.identifier()).form.difficulty"
    }

    static var effortItemIdentifier: String {
        "\(Self.identifier()).form.effort"
    }
}

#if canImport(ResearchKit)
extension PostWorkoutRating {
    func createSurvey() -> ORKTask {

        let difficultyAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 10,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "Very difficult",
            minimumValueDescription: "Very Easy"
        )

        let difficultyItem = ORKFormItem(
            identifier: Self.difficultyItemIdentifier,
            text: "How would you rate your workout difficulty?",
            answerFormat: difficultyAnswerFormat
        )
        difficultyItem.isOptional = false

        let effortAnswerFormat = ORKAnswerFormat.scale(
            withMaximumValue: 10,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "I pushed myself as hard as possible",
            minimumValueDescription: "I did not push myself at all"
        )

        let effortItem = ORKFormItem(
            identifier: Self.effortItemIdentifier,
            text: "How would you rate your workout effort?",
            answerFormat: effortAnswerFormat
        )
        effortItem.isOptional = false

        let formStep = ORKFormStep(
            identifier: Self.formIdentifier,
            title: "Check In",
            text: "Please answer the following questions."
        )
        formStep.formItems = [difficultyItem, effortItem]
        formStep.isOptional = false

        let surveyTask = ORKOrderedTask(
            identifier: identifier(),
            steps: [formStep]
        )
        return surveyTask
    }

    func extractAnswers(_ result: ORKTaskResult) -> [OCKOutcomeValue]? {

        guard
            let response = result.results?
                .compactMap({ $0 as? ORKStepResult })
                .first(where: { $0.identifier == Self.formIdentifier }),

            let scaleResults = response
                .results?.compactMap({ $0 as? ORKScaleQuestionResult }),

            let difficultyAnswer = scaleResults
                .first(where: { $0.identifier == Self.difficultyItemIdentifier })?
                .scaleAnswer,

            let effortAnswer = scaleResults
                .first(where: { $0.identifier == Self.effortItemIdentifier })?
                .scaleAnswer
        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        var difficultyValue = OCKOutcomeValue(Double(truncating: difficultyAnswer))
        difficultyValue.kind = Self.difficultyItemIdentifier

        var effortValue = OCKOutcomeValue(Double(truncating: effortAnswer))
        effortValue.kind = Self.effortItemIdentifier

        return [difficultyValue, effortValue]
    }
}
#endif
