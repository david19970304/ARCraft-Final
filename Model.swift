//
//  Model.swift
//  ModelPickerApp
//
//  Created by David Tsang on 3/1/2023.
//

import UIKit
import RealityKit
import Combine

class Model {
    var name: String
    var image: UIImage
    var modelEntity: ModelEntity?
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String) {
        self.name = modelName
        self.image = UIImage(named: modelName)!
        
        let filename = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: filename)
            .sink(receiveCompletion: { loadCompletion in
                // Handle our error
                print("DEBUG: Unable to load modelEntity for modelName: \(modelName)")
            }, receiveValue: { modelEntity in
                modelEntity.generateCollisionShapes(recursive: true)
                self.modelEntity = modelEntity
                print("DEBUG: Successfully loaded modelEntity for modelName: \(modelName)")
            })
    }
}
