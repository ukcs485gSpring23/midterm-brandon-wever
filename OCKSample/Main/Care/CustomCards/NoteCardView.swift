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

struct NoteCardView: View {
    @Environment(\.careKitStyle) var style
    @StateObject var viewModel: NoteCardViewModel

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
                    Text("✏️: ")
                        .font(Font.headline)
                    TextField("Leave your note here",
                              text: $viewModel.valueAsString)
                              // formatter: viewModel.amountFormatter)
                    .keyboardType(.default)
                        .font(Font.body)
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

struct NoteCardView_Previews: PreviewProvider {
    static var previews: some View {
        NoteCardView(viewModel: .init(storeManager: .init(wrapping: OCKStore(name: Constants.noCareStoreName,
                                                                               type: .inMemory))))
    }
}
