//
//  WeighIn.swift
//  OCKSample
//
//  Created by  on 5/2/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import CareKitStore
#if canImport(ResearchKit)
import ResearchKit
#endif

struct WeighIn: Surveyable {
    static var surveyType: Survey {
        Survey.weighIn
    }

    static var formIdentifier: String {
        "\(Self.identifier()).form"
    }

    static var weightItemIdentifier: String {
        "\(Self.identifier()).form.weight"
    }

    static var caloriesItemIdentifier: String {
        "\(Self.identifier()).form.calories"
    }
}

#if canImport(ResearchKit)
extension WeighIn {
    func createSurvey() -> ORKTask {

        let weightAnswerFormat = ORKAnswerFormat.weightAnswerFormat(with: .metric, numericPrecision: .default)

        let weightItem = ORKFormItem(
            identifier: Self.weightItemIdentifier,
            text: "What is your current weight?",
            answerFormat: weightAnswerFormat
        )
        weightItem.isOptional = false

        let caloriesAnswerFormat = ORKAnswerFormat.integerAnswerFormat(withUnit: "calories")

        let caloriesItem = ORKFormItem(
            identifier: Self.caloriesItemIdentifier,
            text: "How many calories have you consumed today?",
            answerFormat: caloriesAnswerFormat
        )
        caloriesItem.isOptional = false

        let formStep = ORKFormStep(
            identifier: Self.formIdentifier,
            title: "Weigh In",
            text: "Please answer the following questions."
        )
        formStep.formItems = [weightItem, caloriesItem]
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

            let results = response
                .results?.compactMap({ $0 as? ORKNumericQuestionResult }),

            let weightAnswer = results
                .first(where: { $0.identifier == Self.weightItemIdentifier })?
                .numericAnswer,

            let caloriesAnswer = results
                .first(where: { $0.identifier == Self.caloriesItemIdentifier })?
                .numericAnswer
        else {
            assertionFailure("Failed to extract answers from check in survey!")
            return nil
        }

        var weightValue = OCKOutcomeValue(Double(truncating: weightAnswer))
        weightValue.kind = Self.weightItemIdentifier

        var caloriesValue = OCKOutcomeValue(Double(truncating: caloriesAnswer))
        caloriesValue.kind = Self.caloriesItemIdentifier

        return [weightValue, caloriesValue]
    }
}
#endif
