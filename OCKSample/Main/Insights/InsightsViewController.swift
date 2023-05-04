//
//  InsightsViewController.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

/*
 You should notice this looks like CareViewController and
 MyContactViewController combined,
 but only shows charts instead.
*/

import UIKit
import CareKitStore
import CareKitUI
import CareKit
import ParseSwift
import ParseCareKit
import os.log

class InsightsViewController: OCKListViewController {

    /// The manager of the `Store` from which the `Contact` data is fetched.
    public let storeManager: OCKSynchronizedStoreManager

    /// Initialize using a store manager. All of the contacts in the store manager will be queried and dispalyed.
    ///
    /// - Parameters:
    ///   - storeManager: The store manager owning the store whose contacts should be displayed.
    public init(storeManager: OCKSynchronizedStoreManager) {
        self.storeManager = storeManager
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Insights"

        Task {
            await displayTasks(Date())
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        Task {
            await displayTasks(Date())
        }
    }

    override func appendViewController(_ viewController: UIViewController, animated: Bool) {
        super.appendViewController(viewController, animated: animated)

        // Make sure this contact card matches app style when possible
        if let carekitView = viewController.view as? OCKView {
            carekitView.customStyle = CustomStylerKey.defaultValue
        }
    }

    @MainActor
    func fetchTasks(on date: Date) async -> [OCKAnyTask] {
        /**
         TODOxxx: How would you modify this to fetch all of your tasks?
         Hint - you should look at the same function in CareViewController. If you
         understand queries and filters, this will be straightforward.
         */
        var query = OCKTaskQuery(for: date)
        query.excludesTasksWithNoEvents = true
        do {
            let tasks = try await storeManager.store.fetchAnyTasks(query: query)
            return tasks.filter { $0.id != Onboard.identifier() }
        } catch {
            Logger.insights.error("\(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    /*
     TODOxxx: Plot all of your tasks in this method. Note that you can combine multiple
     tasks into one chart (like the Nausea/Doxlymine chart if they are related.
    */

    func taskViewController(for task: OCKAnyTask,
                            on date: Date) -> [UIViewController]? {
        /*
         TODOxxx: CareKit has 3 plotType's: .bar, .scatter, and .line.
         You should have a 3 types in your InsightView meaning you
         should have at least 3 charts. Remember that all of your
         tasks need to be graphed so you may have more. The solution
         for not this should not be to show all 3 plot types for a
         single task. Your code should be flexible enough to determine
         a graph type. Instead, you should look extend OCKTask and OCKAnyTask
         to add a "graph" property similar to "card". This means you probably
         should create a "GraphCard" enum similar to "CareKitCard" and allow
         the user to select the specific graph when adding a new task.
         Hint - you should look at the same function in CareViewController
         to determine how to switch graphs on an enum.
         */

        let survey = CheckIn() // Only used for example.
        let surveyTaskID = survey.identifier() // Only used for example.

        switch task.id {
        case surveyTaskID:

            /*
             Note that that there's a small bug for the check in graph because
             it averages all of the "Pain + Sleep" hours. This okay for now. If
             you are collecting ResearchKit input that only collects 1 value per
             survey, you won't have this problem.
             */

            // dynamic gradient colors
            let meanGradientStart = TintColorFlipKey.defaultValue
            let meanGradientEnd = TintColorKey.defaultValue

            // Create a plot comparing mean to median.
            let meanDataSeries = OCKDataSeriesConfiguration(
                taskID: surveyTaskID,
                legendTitle: "Mean",
                gradientStartColor: meanGradientStart,
                gradientEndColor: meanGradientEnd,
                markerSize: 10,
                eventAggregator: .aggregatorMean(CheckIn.sleepItemIdentifier))

            let medianDataSeries = OCKDataSeriesConfiguration(
                taskID: surveyTaskID,
                legendTitle: "Median",
                gradientStartColor: .systemGray2,
                gradientEndColor: .systemGray,
                markerSize: 10,
                eventAggregator: .aggregatorMedian(CheckIn.sleepItemIdentifier))

            let insightsCard = OCKCartesianChartViewController(
                plotType: .line,
                selectedDate: date,
                configurations: [meanDataSeries, medianDataSeries],
                storeManager: self.storeManager)

            insightsCard.chartView.headerView.titleLabel.text = "Sleep Mean & Median"
            insightsCard.chartView.headerView.detailLabel.text = "This Week"
            insightsCard.chartView.headerView.accessibilityLabel = "Mean & Median, This Week"

            return [insightsCard]

        case WeighIn().identifier():
            let weightGradientEnd = TintColorKey.defaultValue

            let meanDataSeries = OCKDataSeriesConfiguration(
                taskID: WeighIn().identifier(),
                legendTitle: "Mean",
                gradientStartColor: weightGradientEnd,
                gradientEndColor: weightGradientEnd,
                markerSize: 5,
                eventAggregator: .aggregatorMean(WeighIn.weightItemIdentifier))

            let medianDataSeries = OCKDataSeriesConfiguration(
                taskID: WeighIn().identifier(),
                legendTitle: "Median",
                gradientStartColor: .systemGray2,
                gradientEndColor: .systemGray,
                markerSize: 5,
                eventAggregator: .aggregatorMedian(WeighIn.weightItemIdentifier))

            let weightInsightsCard = OCKCartesianChartViewController(
                plotType: .line,
                selectedDate: date,
                configurations: [meanDataSeries, medianDataSeries],
                storeManager: self.storeManager)

            weightInsightsCard.chartView.headerView.titleLabel.text = "Weight Mean & Median"
            weightInsightsCard.chartView.headerView.detailLabel.text = "This Week"
            weightInsightsCard.chartView.headerView.accessibilityLabel = "Mean & Median, This Week"

            return [weightInsightsCard]

        case PostWorkoutRating().identifier():
            var cards = [UIViewController]()
            // dynamic gradient colors
            let difficultyGradientEnd = TintColorKey.defaultValue

            // Create a plot comparing nausea to medication adherence.
            let difficultyDataSeries = OCKDataSeriesConfiguration(
                taskID: PostWorkoutRating().identifier(),
                legendTitle: "Difficulty",
                gradientStartColor: difficultyGradientEnd,
                gradientEndColor: difficultyGradientEnd,
                markerSize: 10,
                eventAggregator: .aggregatorMean(PostWorkoutRating.difficultyItemIdentifier))

            let effortDataSeries = OCKDataSeriesConfiguration(
                taskID: PostWorkoutRating().identifier(),
                legendTitle: "Effort",
                gradientStartColor: .systemGray2,
                gradientEndColor: .systemGray,
                markerSize: 10,
                eventAggregator: .aggregatorMean(PostWorkoutRating.effortItemIdentifier))

            let insightsCard = OCKCartesianChartViewController(
                plotType: .bar,
                selectedDate: date,
                configurations: [difficultyDataSeries, effortDataSeries],
                storeManager: self.storeManager)

            insightsCard.chartView.headerView.titleLabel.text = "Workout Difficulty This Week"
            insightsCard.chartView.headerView.detailLabel.text = "This Week"
            insightsCard.chartView.headerView.accessibilityLabel = "Workout Difficulty This Week"
            cards.append(insightsCard)

            return cards

        case TaskID.completedExercise:
            var cards = [UIViewController]()
            let completedExerciseGradient = TintColorKey.defaultValue

            let completedExerciseDataSeries = OCKDataSeriesConfiguration(
                taskID: TaskID.completedExercise,
                legendTitle: "Completed Exercises",
                gradientStartColor: completedExerciseGradient,
                gradientEndColor: completedExerciseGradient,
                markerSize: 5,
                eventAggregator: OCKEventAggregator.countOutcomeValues)

            let insightsCard = OCKCartesianChartViewController(
                            plotType: .scatter,
                            selectedDate: date,
                            configurations: [completedExerciseDataSeries],
                            storeManager: self.storeManager)

            insightsCard.chartView.headerView.titleLabel.text = "Exercises Completed"
                insightsCard.chartView.headerView.detailLabel.text = "This Week"
                insightsCard.chartView.headerView.accessibilityLabel = "Exercises Completed, This Week"
                cards.append(insightsCard)

            return cards

        default:
            return nil
        }
    }

    @MainActor
    func displayTasks(_ date: Date) async {

        let tasks = await fetchTasks(on: date)
        self.clear() // Clear after pulling tasks from database
        tasks.compactMap {
            let cards = self.taskViewController(for: $0, on: date)
            cards?.forEach {
                if let carekitView = $0.view as? OCKView {
                    carekitView.customStyle = CustomStylerKey.defaultValue
                }
            }
            return cards
        }.forEach { (cards: [UIViewController]) in
            cards.forEach {
                self.appendViewController($0, animated: false)
            }
        }
    }
}
