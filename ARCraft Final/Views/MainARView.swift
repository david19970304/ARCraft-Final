//
//  MainARView.swift
//  ModelPickerApp
//
//  Created by David Tsang on 5/1/2023.
//

import SwiftUI

struct MainARView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var models: [Model]
    
    @ObservedObject var arView: FocusARView = FocusARView(frame: .zero)
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: $modelConfirmedForPlacement, arView: arView)
            
            if isPlacementEnabled {
                PlacementButtonView(
                    isPlacementEnabled: $isPlacementEnabled,
                    selectedModel: $selectedModel,
                    modelConfirmedForPlacement: $modelConfirmedForPlacement
                )
            } else {
                ModelPickerView(isPlacementEnabled: $isPlacementEnabled, selectedModel: $selectedModel, models: models)
            }
        }
        
    }
}

//struct MainARView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainARView()
//    }
//}
