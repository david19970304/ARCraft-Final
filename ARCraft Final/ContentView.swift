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
    @State private var selectedTab: Int = 0
    
    
    var body: some View {
        Picker("", selection: $selectedTab) {
            Text("Preview Mode").tag(0)
            Text("AR Mode").tag(1)
            
        }.pickerStyle(SegmentedPickerStyle())
  

        switch(selectedTab) {
            case 0: MainPreviewObjectView(models: $models)
            case 1: MainARView(isPlacementEnabled: $isPlacementEnabled,
                                  selectedModel: $selectedModel,
                                  modelConfirmedForPlacement: $modelConfirmedForPlacement,
                                  models: $models
            )
        default: MainPreviewObjectView(models: $models)
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
    @Binding var modelConfirmedForPlacement: Model?
    @ObservedObject var arView: FocusARView

    func makeUIView(context: Context) -> ARView {
        arView.enableObjectRemoval()
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = modelConfirmedForPlacement {
            
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene - \(model.name)")
                
//                let anchorEntity = AnchorEntity()
                let anchorEntity = AnchorEntity(plane: .any)
                
                let newEntity = modelEntity.clone(recursive: true)
                
                // AR Object can be moved, roatated, and scaled
                uiView.installGestures([.translation, .rotation, .scale], for: newEntity)
                
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
