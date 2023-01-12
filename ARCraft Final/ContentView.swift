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
    @State private var fadeInOut = false
    @State private var hasObject = false
    
    
    var body: some View {
        Picker("", selection: $selectedTab) {
            Text("Preview Mode").tag(0)
            Text("AR Mode").tag(1)
            
        }.pickerStyle(SegmentedPickerStyle())
        .onAppear{
                loadModelFilesFromDownloadedContent()
            }
  

        switch(selectedTab) {
            case 0: MainPreviewObjectView(models: $models)
            case 1: MainARView(isPlacementEnabled: $isPlacementEnabled,
                                  selectedModel: $selectedModel,
                                  modelConfirmedForPlacement: $modelConfirmedForPlacement,
                                  fadeInOut: $fadeInOut,
                                  hasObject: $hasObject,
                                  models: $models
            )
        default: MainPreviewObjectView(models: $models)
        }
        
        if (selectedTab == 0) {
            HStack (alignment: .bottom) {
                Spacer()
                Button {
                    removeAllDownloadedContent()
                } label: {
                    Label("Remove All", systemImage: "icloud.slash")
                }.buttonStyle(RoundedRectangleButtonStyle())
                Spacer()
                
                Button {
                    loadModelFilesFromDownloadedContent()
                } label: {
                    Label("Firebase", systemImage: "icloud.and.arrow.down")
                }.buttonStyle(RoundedRectangleButtonStyle())
                Spacer()
            }
        }
    }
    
    func loadModelFilesFromDownloadedContent() {
        let storageManager = StorageManager()
        storageManager.getFilesFromFireBase()
        
        storageManager.callBack = { name in
            let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let downloadedContentFolder = root.appendingPathComponent("DownloadedContent")
//            let files = try? FileManager.default.contentsOfDirectory(atPath: downloadedContentFolder.path)
            let imageUrl = downloadedContentFolder.appendingPathComponent("\(name)/image.jpg")
            let objectUrl = downloadedContentFolder.appendingPathComponent("\(name)/object.usdz")
            
            let imageIsExisted = FileManager.default.fileExists(atPath: imageUrl.path)
            let objectIsExisted = FileManager.default.fileExists(atPath: objectUrl.path)
            
            if imageIsExisted == true && objectIsExisted == true {
                DispatchQueue.main.async {
                    let isAlreadyExisted = models.contains{$0.name == name}
                    
                    if (!isAlreadyExisted) {
                        models.append(Model(modelName: name, isInDownloadedContent: true))
                    }
                }
            }
        }
    }
    
    func removeAllDownloadedContent() {
        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let downloadedContentFolder = root.appendingPathComponent("DownloadedContent")
        
        do {
            try FileManager().removeItem(at: downloadedContentFolder)
            DispatchQueue.main.async {
                models = models.filter{$0.isDownloadedContent == false}
            }
        } catch {
            print(error)
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
    @Binding var hasObject: Bool
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
                
                DispatchQueue.main.async {
                    hasObject = true
                }
                
                
            } else {
                print("DEBUG: Unable to load modelEntity for \(model.name)")
            }

            DispatchQueue.main.async {
                modelConfirmedForPlacement = nil
                
                arView.callBack = {
                    if uiView.scene.anchors.count <= 2 {
                        hasObject = false
                    }
                }
                
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
