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
    var isDownloadedContent: Bool = false
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
    
    init(modelName: String, isInDownloadedContent: Bool) {
        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl = root.appendingPathComponent("DownloadedContent/\(modelName)/image.jpg")
        let objectUrl = root.appendingPathComponent("DownloadedContent/\(modelName)/object.usdz")
        
        self.name = modelName
        let imageData = try! Data(contentsOf: imageUrl)
        self.image = UIImage(data: imageData)!
        self.isDownloadedContent = isInDownloadedContent
        
        self.cancellable = ModelEntity.loadModelAsync(contentsOf: objectUrl, withName: modelName)
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
