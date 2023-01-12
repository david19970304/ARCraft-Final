//
//  ContentView.swift
//  ARCraft Final
//
//  Created by David Tsang on 12/1/2023.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var models: [Model] = getModelFilenames()
    @State var modelConfirmedForPlacement: Model?
    @State var isPlacementEnabled: Bool = false
    @State private var selectedModel: Model?
    @ObservedObject var arView: FocusARView = FocusARView(frame: .zero)
    
    
    var body: some View {
        ARViewContainer(arView: arView, modelConfirmedForPlacement: $modelConfirmedForPlacement, models: $models)
        
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

func getModelFilenames() -> [Model] {
        
        // Dynamically get our model filenames
        let fileManager = FileManager.default
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModels: [Model] = []
        
        for filename in files where filename.hasSuffix("usdz") {
            let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            availableModels.append(model)
        }
    
    
        
        return availableModels
}

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var arView: FocusARView
    @Binding var modelConfirmedForPlacement: Model?
    @Binding var models: [Model]

    func makeUIView(context: Context) -> ARView {
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = modelConfirmedForPlacement {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene - \(model.name)")
                
//                let anchorEntity = AnchorEntity()
                let anchorEntity = AnchorEntity(plane: .any)
                
                let newEntity = modelEntity.clone(recursive: true)
                
                anchorEntity.addChild(newEntity)
                
                uiView.scene.addAnchor(anchorEntity)
                
                
            } else {
                print("DEBUG: Unable to load modelEntity for \(model.name)")
            }

            DispatchQueue.main.async {
                modelConfirmedForPlacement = nil
                
            }
            
        }
        
    }
    
}

#if DEBUG
//struct ContentView_Previews : PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
#endif
