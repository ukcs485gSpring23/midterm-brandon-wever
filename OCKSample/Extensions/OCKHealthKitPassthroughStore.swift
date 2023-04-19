//
//  OCKHealthKitPassthroughStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import HealthKit
import os.log

extension OCKHealthKitPassthroughStore {

    func addTasksIfNotPresent(_ tasks: [OCKHealthKitTask]) async throws {
        let tasksToAdd = tasks
        let taskIdsToAdd = tasksToAdd.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKHealthKitTask]()

        // Check results to see if there's a missing task
        tasksToAdd.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockHealthKitPassthroughStore.info("Added tasks into HealthKitPassthroughStore!")
            } catch {
                Logger.ockHealthKitPassthroughStore.error("Error adding HealthKitTasks: \(error)")
            }
        }
    }

    func populateCarePlans(patientUUID: UUID? = nil) async throws -> UUID {

            let userCarePlan = OCKCarePlan(id: CarePlanID.user.rawValue,
                                           title: "User Care Plan",
                                           patientUUID: patientUUID)

            try await AppDelegateKey
                .defaultValue?
                .storeManager
                .addCarePlansIfNotPresent([userCarePlan],
                                          patientUUID: patientUUID)
        return userCarePlan.uuid
        }

    /*
     TODOx: You need to tie an OCKPatient.
    */
    func populateSampleData(_ patientUUID: UUID? = nil) async throws {
        let carePlanUUID = try await populateCarePlans(patientUUID: patientUUID)

        let schedule = OCKSchedule.dailyAtTime(
            hour: 8, minutes: 0, start: Date(), end: nil, text: nil,
            duration: .hours(12), targetValues: [OCKOutcomeValue(2000.0, units: "Steps")])

        /*
        TODOx: You need to tie an OCKCarePlan to each HealthKit task. There was a
        a method added recently in Extensions/OCKStore.swift to assist with this. Use this method here
        and write a comment and state if it's an "instance method" or "type method". If you
        are trying to copy the method to this file, you are using the code incorrectly. Be
        sure to understand the difference between a type method and instance method.
        */
        var steps = OCKHealthKitTask(
            id: TaskID.steps,
            title: "Steps",
            carePlanUUID: carePlanUUID,
            schedule: schedule,
            healthKitLinkage: OCKHealthKitLinkage(
                quantityIdentifier: .stepCount,
                quantityType: .cumulative,
                unit: .count()))
        steps.asset = "figure.walk"
        steps.card = .numericProgress
        // uncomment to get sample steps card back
        try await addTasksIfNotPresent([steps])
    }
}
