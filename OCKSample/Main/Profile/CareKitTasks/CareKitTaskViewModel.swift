//
//  CareKitTaskViewModel.swift
//  OCKSample
//
//  Created by Corey Baker on 3/21/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import os.log

class CareKitTaskViewModel: ObservableObject {
    @Published var title = ""
    @Published var instructions = ""
    @Published var selectedCard: CareKitCard = .button
    @Published var selectedSchedule = "Every Day"

    @Published var error: AppError? {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    private func setSchedule(userSchedule: String) -> OCKSchedule {
        switch userSchedule {
        case "Every Day":
            return OCKSchedule.dailyAtTime(hour: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            text: nil)
        case "Every Other Day":
            return OCKSchedule.dailyAtTime(hour: 0,
                                           minutes: 0,
                                           start: Date() + 1,
                                           end: nil,
                                           text: nil)
        case "Once a Week on Sunday":
            return OCKSchedule.weeklyAtTime(weekday: 1,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        case "Once a Week on Monday":
            return OCKSchedule.weeklyAtTime(weekday: 2,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        case "Once a Week on Tuesday":
            return OCKSchedule.weeklyAtTime(weekday: 3,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        case "Once a Week on Wednesday":
            return OCKSchedule.weeklyAtTime(weekday: 4,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        case "Once a Week on Thursday":
            return OCKSchedule.weeklyAtTime(weekday: 5,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        case "Once a Week on Friday":
            return OCKSchedule.weeklyAtTime(weekday: 6,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        case "Once a Week on Saturday":
            return OCKSchedule.weeklyAtTime(weekday: 7,
                                            hours: 0,
                                            minutes: 0,
                                            start: Date(),
                                            end: nil,
                                            targetValues: [],
                                            text: nil)
        default:
            return OCKSchedule.dailyAtTime(hour: 0,
                                           minutes: 0,
                                           start: Date(),
                                           end: nil,
                                           text: nil)
        }
    }

    // MARK: Intents
    func addTask() async {
        guard let appDelegate = AppDelegateKey.defaultValue else {
            error = AppError.couldntBeUnwrapped
            return
        }
        let uniqueId = UUID().uuidString // Create a unique id for each task
        var task = OCKTask(id: uniqueId,
                           title: title,
                           carePlanUUID: nil,
                           schedule: .dailyAtTime(hour: 0,
                                                  minutes: 0,
                                                  start: Date(),
                                                  end: nil,
                                                  text: nil))
        task.instructions = instructions
        task.card = selectedCard
        task.schedule = setSchedule(userSchedule: selectedSchedule)

        do {
            try await appDelegate.storeManager.addTasksIfNotPresent([task])
            Logger.careKitTask.info("Saved task: \(task.id, privacy: .private)")
            // Notify views they should refresh tasks if needed
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
        } catch {
            self.error = AppError.errorString("Could not add task: \(error.localizedDescription)")
        }
    }

    func addHealthKitTask() async {
        guard let appDelegate = AppDelegateKey.defaultValue else {
            error = AppError.couldntBeUnwrapped
            return
        }
        let uniqueId = UUID().uuidString // Create a unique id for each task
        var healthKitTask = OCKHealthKitTask(id: uniqueId,
                                             title: title,
                                             carePlanUUID: nil,
                                             schedule: .dailyAtTime(hour: 0,
                                                                    minutes: 0,
                                                                    start: Date(),
                                                                    end: nil,
                                                                    text: nil),
                                             healthKitLinkage: .init(quantityIdentifier: .electrodermalActivity,
                                                                     quantityType: .discrete,
                                                                     unit: .count()))
        healthKitTask.instructions = instructions
        healthKitTask.card = selectedCard
        healthKitTask.schedule = setSchedule(userSchedule: selectedSchedule)
        do {
            try await appDelegate.storeManager.addTasksIfNotPresent([healthKitTask])
            Logger.careKitTask.info("Saved HealthKitTask: \(healthKitTask.id, privacy: .private)")
            // Notify views they should refresh tasks if needed
            NotificationCenter.default.post(.init(name: Notification.Name(rawValue: Constants.shouldRefreshView)))
            // Ask HealthKit store for permissions after each new task
            Utility.requestHealthKitPermissions()
        } catch {
            self.error = AppError.errorString("Could not add task: \(error.localizedDescription)")
        }
    }
}
