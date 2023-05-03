//
//  OCKStore.swift
//  OCKSample
//
//  Created by Corey Baker on 1/5/22.
//  Copyright © 2022 Network Reconnaissance Lab. All rights reserved.
//

import Foundation
import CareKitStore
import Contacts
import os.log
import ParseSwift
import ParseCareKit

extension OCKStore {

    func addTasksIfNotPresent(_ tasks: [OCKTask]) async throws {
        let taskIdsToAdd = tasks.compactMap { $0.id }

        // Prepare query to see if tasks are already added
        var query = OCKTaskQuery(for: Date())
        query.ids = taskIdsToAdd

        let foundTasks = try await fetchTasks(query: query)
        var tasksNotInStore = [OCKTask]()

        // Check results to see if there's a missing task
        tasks.forEach { potentialTask in
            if foundTasks.first(where: { $0.id == potentialTask.id }) == nil {
                tasksNotInStore.append(potentialTask)
            }
        }

        // Only add if there's a new task
        if tasksNotInStore.count > 0 {
            do {
                _ = try await addTasks(tasksNotInStore)
                Logger.ockStore.info("Added tasks into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding tasks: \(error)")
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

    @MainActor
    class func getCarePlanUUIDs() async throws -> [CarePlanID: UUID] {
        var results = [CarePlanID: UUID]()

        guard let store = AppDelegateKey.defaultValue?.store else {
            return results
        }

        var query = OCKCarePlanQuery(for: Date())
        query.ids = [CarePlanID.health.rawValue,
                         CarePlanID.checkIn.rawValue]

        let foundCarePlans = try await store.fetchCarePlans(query: query)
        // Populate the dictionary for all CarePlan's
        CarePlanID.allCases.forEach { carePlanID in
            results[carePlanID] = foundCarePlans
                .first(where: { $0.id == carePlanID.rawValue })?.uuid
        }
        return results
    }

    func addContactsIfNotPresent(_ contacts: [OCKContact]) async throws {
        let contactIdsToAdd = contacts.compactMap { $0.id }

        // Prepare query to see if contacts are already added
        var query = OCKContactQuery(for: Date())
        query.ids = contactIdsToAdd

        let foundContacts = try await fetchContacts(query: query)
        var contactsNotInStore = [OCKContact]()

        // Check results to see if there's a missing task
        contacts.forEach { potential in
            if foundContacts.first(where: { $0.id == potential.id }) == nil {
                contactsNotInStore.append(potential)
            }
        }

        // Only add if there's a new task
        if contactsNotInStore.count > 0 {
            do {
                _ = try await addContacts(contactsNotInStore)
                Logger.ockStore.info("Added contacts into OCKStore!")
            } catch {
                Logger.ockStore.error("Error adding contacts: \(error)")
            }
        }
    }

    // Adds tasks and contacts into the store
    func populateSampleData(_ patientUUID: UUID? = nil) async throws {

        let carePlanUUID = try await populateCarePlans(patientUUID: patientUUID)

        let thisMorning = Calendar.current.startOfDay(for: Date())

        guard let aFewDaysAgo = Calendar.current.date(byAdding: .day, value: -4, to: thisMorning),
                      let beforeBreakfast = Calendar.current.date(byAdding: .hour, value: 8, to: aFewDaysAgo),
                      let afterLunch = Calendar.current.date(byAdding: .hour, value: 14, to: aFewDaysAgo) else {
                    Logger.ockStore.error("Could not unwrap calendar. Should never hit")
                    throw AppError.couldntBeUnwrapped
                }

        let schedule = OCKSchedule(composing: [
            OCKScheduleElement(start: beforeBreakfast,
                               end: nil,
                               interval: DateComponents(day: 1)),

            OCKScheduleElement(start: afterLunch,
                               end: nil,
                               interval: DateComponents(day: 2))
        ])

        var warmup = OCKTask(id: TaskID.warmUp,
                             title: "Warm Up",
                             carePlanUUID: carePlanUUID,
                             schedule: schedule)
        warmup.instructions = "Do some light cardio for a couple of minutes to increase your body's bloodflow"
        warmup.card = .instruction
        warmup.impactsAdherence = true

        var benchPress = OCKTask(id: TaskID.benchPress,
                                 title: "Bench Press",
                                 carePlanUUID: carePlanUUID,
                                 schedule: schedule)
        benchPress.instructions = "Perform 10 repititions of bench press with a reasonable weight"
        benchPress.card = .simple
        benchPress.impactsAdherence = true

        var core = OCKTask(id: TaskID.core,
                           title: "Core Exercises",
                           carePlanUUID: carePlanUUID,
                           schedule: schedule)
        core.instructions = "Do core exercises at the following times and mark them complete."
        core.card = .checklist

        let completedSchedule = OCKSchedule(composing: [
        OCKScheduleElement(start: beforeBreakfast,
                           end: nil, interval: DateComponents(day: 1),
                           text: "Log throughout your workout",
                           targetValues: [],
                           duration: .allDay)
        ])
        var completedExercise = OCKTask(id: TaskID.completedExercise,
                                        title: "Completed an Exercise",
                                        carePlanUUID: carePlanUUID,
                                        schedule: completedSchedule)
        completedExercise.instructions = "Tap the button to log everytime you have completed an exercise"
        completedExercise.card = .button
        completedExercise.impactsAdherence = false

         var repetition = OCKTask(id: TaskID.repetition,
                                  title: "Track your Bench",
                                  carePlanUUID: carePlanUUID,
                                  schedule: schedule)
         repetition.impactsAdherence = false
         repetition.instructions = "Input your attempted bench press weight before you start."
         repetition.asset = "repeat.circle"
         repetition.card = .custom

        var chatgtpLink = OCKTask(id: TaskID.chatgtp,
                                  title: "ChatGTP Link",
                                  carePlanUUID: carePlanUUID,
                                  schedule: schedule)
        chatgtpLink.card = .link
        chatgtpLink.instructions = "Ask ChatGTP about your workout questions!"
        chatgtpLink.impactsAdherence = false

        try await addTasksIfNotPresent([chatgtpLink, warmup, benchPress, core, completedExercise, repetition])

        let carePlanUUIDs = try await Self.getCarePlanUUIDs()
        try await addOnboardingTask(carePlanUUIDs[.health])
        try await addSurveyTasks(carePlanUUIDs[.checkIn])

        var contact1 = OCKContact(id: "jane",
                                  givenName: "Jane",
                                  familyName: "Daniels",
                                  carePlanUUID: carePlanUUID)
        contact1.asset = "JaneDaniels"
        contact1.title = "Family Practice Doctor"
        contact1.role = "Dr. Daniels is a family practice doctor with 8 years of experience."
        contact1.emailAddresses = [OCKLabeledValue(label: CNLabelEmailiCloud, value: "janedaniels@uky.edu")]
        contact1.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-2000")]
        contact1.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 357-2040")]

        contact1.address = {
            let address = OCKPostalAddress()
            address.street = "2195 Harrodsburg Rd"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40504"
            return address
        }()

        var contact2 = OCKContact(id: "matthew", givenName: "Matthew",
                                  familyName: "Reiff", carePlanUUID: carePlanUUID)
        contact2.asset = "MatthewReiff"
        contact2.title = "OBGYN"
        contact2.role = "Dr. Reiff is an OBGYN with 13 years of experience."
        contact2.phoneNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1000")]
        contact2.messagingNumbers = [OCKLabeledValue(label: CNLabelWork, value: "(859) 257-1234")]
        contact2.address = {
            let address = OCKPostalAddress()
            address.street = "1000 S Limestone"
            address.city = "Lexington"
            address.state = "KY"
            address.postalCode = "40536"
            return address
        }()

        try await addContactsIfNotPresent([contact1, contact2])

        func addOnboardingTask(_ carePlanUUID: UUID? = nil) async throws {
                let onboardSchedule = OCKSchedule.dailyAtTime(
                            hour: 0, minutes: 0,
                            start: Date(), end: nil,
                            text: "Task Due!",
                            duration: .allDay
                        )

                var onboardTask = OCKTask(
                    id: Onboard.identifier(),
                    title: "Onboard",
                    carePlanUUID: carePlanUUID,
                    schedule: onboardSchedule
                )
                onboardTask.instructions = "You'll need to agree to some terms and conditions before we get started!"
                onboardTask.impactsAdherence = false
                onboardTask.card = .survey
                onboardTask.survey = .onboard

                try await addTasksIfNotPresent([onboardTask])
            }

            func addSurveyTasks(_ carePlanUUID: UUID? = nil) async throws {
                let checkInSchedule = OCKSchedule.dailyAtTime(
                    hour: 8, minutes: 0,
                    start: Date(), end: nil,
                    text: nil
                )

                var checkInTask = OCKTask(
                    id: CheckIn.identifier(),
                    title: "Check In",
                    carePlanUUID: carePlanUUID,
                    schedule: checkInSchedule
                )
                checkInTask.card = .survey
                checkInTask.survey = .checkIn

                var weighInTask = OCKTask(
                    id: WeighIn.identifier(),
                    title: "Weigh In",
                    carePlanUUID: carePlanUUID,
                    schedule: checkInSchedule
                )
                weighInTask.card = .survey
                weighInTask.survey = .weighIn

                var postWorkoutRatingTask = OCKTask(id: PostWorkoutRating.identifier(),
                                                    title: "Post Workout Evaluation",
                                                    carePlanUUID: carePlanUUID,
                                                    schedule: checkInSchedule)
                postWorkoutRatingTask.card = .survey
                postWorkoutRatingTask.survey = .postWorkoutRating

                let thisMorning = Calendar.current.startOfDay(for: Date())

                let nextWeek = Calendar.current.date(
                    byAdding: .weekOfYear,
                    value: 1,
                    to: Date()
                )!

                let nextMonth = Calendar.current.date(
                    byAdding: .month,
                    value: 1,
                    to: thisMorning
                )

                let dailyElement = OCKScheduleElement(
                    start: thisMorning,
                    end: nextWeek,
                    interval: DateComponents(day: 1),
                    text: nil,
                    targetValues: [],
                    duration: .allDay
                )

                let weeklyElement = OCKScheduleElement(
                    start: nextWeek,
                    end: nextMonth,
                    interval: DateComponents(weekOfYear: 1),
                    text: nil,
                    targetValues: [],
                    duration: .allDay
                )

                let rangeOfMotionCheckSchedule = OCKSchedule(
                    composing: [dailyElement, weeklyElement]
                )

                var rangeOfMotionTask = OCKTask(
                    id: RangeOfMotion.identifier(),
                    title: "Range Of Motion",
                    carePlanUUID: carePlanUUID,
                    schedule: rangeOfMotionCheckSchedule
                )
                rangeOfMotionTask.card = .survey
                rangeOfMotionTask.survey = .rangeOfMotion

                try await addTasksIfNotPresent([weighInTask, postWorkoutRatingTask])
            }
    }
}
