//
//  SurveyViewSynchronizer.swift
//  OCKSample
//
//  Created by Corey Baker on 4/14/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//
import CareKit
import CareKitStore
import CareKitUI
import ResearchKit
import UIKit
import os.log

final class SurveyViewSynchronizer: OCKSurveyTaskViewSynchronizer {

    override func updateView(_ view: OCKInstructionsTaskView,
                             context: OCKSynchronizationContext<OCKTaskEvents>) {

        super.updateView(view, context: context)

        if let event = context.viewModel.first?.first, event.outcome != nil {
            view.instructionsLabel.isHidden = false
            /*
             TODOxx: You need to modify this so the instuction label shows
             correctly for each Task/Card.
             Hint - Each event (OCKAnyEvent) has a task. How can you use
             this task to determine what instruction answers should show?
             Look at how the CareViewController differentiates between
             surveys.
             */

            if let unwrappedTask = event.task as? OCKTask {
                switch unwrappedTask.survey {
                case .checkIn:
                    let pain = event.answer(kind: CheckIn.painItemIdentifier)
                    let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)

                    view.instructionsLabel.text = """
                        Pain: \(Int(pain))
                        Sleep: \(Int(sleep)) hours
                        """
                case .weighIn:
                    let weight = event.answer(kind: WeighIn.weightItemIdentifier)
                    let calories = event.answer(kind: WeighIn.caloriesItemIdentifier)

                    view.instructionsLabel.text = """
                    Weight: \((Double(weight)*2.20462).rounded(.up)) pounds
                    Calories: \(Int(calories)) calories today
                    """
                case .postWorkoutRating:
                    let difficulty = event.answer(kind: PostWorkoutRating.difficultyItemIdentifier)
                    let effort = event.answer(kind: PostWorkoutRating.effortItemIdentifier)

                    view.instructionsLabel.text = """
                        Difficulty: \(Int(difficulty)) /10
                        Effort: \(Int(effort)) / 10
                        """
                default:
                    let pain = event.answer(kind: CheckIn.painItemIdentifier)
                    let sleep = event.answer(kind: CheckIn.sleepItemIdentifier)

                    view.instructionsLabel.text = """
                        Pain: \(Int(pain))
                        Sleep: \(Int(sleep)) hours
                        """
                }
            }
        } else {
            view.instructionsLabel.isHidden = true
        }
    }
}
