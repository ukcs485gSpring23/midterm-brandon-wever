//
//  CustomCardView.swift
//  OCKSample
//
//  Created by Corey Baker on 4/25/23.
//  Copyright © 2023 Network Reconnaissance Lab. All rights reserved.
//

import SwiftUI
import CareKitUI
import CareKitStore

struct CustomCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: CustomCardViewModel

    var body: some View {
        CardView {

            VStack(alignment: .leading,
                   spacing: style.dimension.directionalInsets1.top) {
                // Can look through HeaderView for creating custom
                HeaderView(title: Text(viewModel.taskEvents.firstEventTitle),
                           detail: Text(viewModel.taskEvents.firstTaskInstructions ?? ""))
                Divider()
                HStack(alignment: .center,
                       spacing: style.dimension.directionalInsets2.trailing) {

                    /*
                     // Example of custom content.
                     TODOxxx: Remove all that you are not using.
                     */
                    Button(action: {
                        Task {
                            await viewModel.action(viewModel.value)
                        }
                        // swiftlint:disable:next multiple_closures_with_trailing_closure
                        }) {
                            CircularCompletionView(isComplete: viewModel.taskEvents.isFirstEventComplete) {
                                Image(systemName: "checkmark") // Can place any view type here
                                    .resizable()
                                    .padding()
                                    .frame(width: 40, height: 40) // Change size to make larger/smaller
                            }
                        }
                    Spacer()

                    Text("Input: ")
                        .font(Font.headline)
                    TextField("0",
                              value: $viewModel.valueAsInt,
                              formatter: viewModel.amountFormatter)
                        .keyboardType(.decimalPad)
                        .font(Font.title.weight(.bold))
                        .foregroundColor(.accentColor)

                }
            }
            .padding()
        }

        .onReceive(viewModel.$taskEvents) { taskEvents in
            /*
             DO NOT CHANGE THIS. The viewModel needs help
             from view to update "value" since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.checkIfValueShouldUpdate(taskEvents)
        }
        .onReceive(viewModel.$error) { error in
            /*
             DO NOT CHANGE THIS. The viewModel needs help
             from view to update "currentError" since taskEvents
             can't be overriden in viewModel.
             */
            viewModel.setError(error)
        }
    }
}

struct CustomCardView_Previews: PreviewProvider {
    static var previews: some View {
        CustomCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                               type: .inMemory))))
    }
}
