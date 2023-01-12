//
//  Edited based on https://github.com/maxxfrazer/FocusEntity/blob/main/FocusEntity-Example/FocusEntity-Example/FocusARView.swift
//  ModelPickerApp
//
//  Created by David Tsang on 3/1/2023.
//

import RealityKit
import FocusEntity
import Combine
import ARKit
import UIKit
import SwiftUI

class FocusARView: ARView, ObservableObject {
    @Published var callBack: () -> Void = {}
  
  var focusEntity: FocusEntity?
  required init(frame frameRect: CGRect) {
      super.init(frame: frameRect)
    self.setupConfig()
    self.focusEntity = FocusEntity(on: self, focus: .classic)
  }
    
  func setupConfig() {
    let config = ARWorldTrackingConfiguration()
    config.planeDetection = [.horizontal, .vertical]
    config.environmentTexturing = .automatic
    
    if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
        config.sceneReconstruction = .mesh
    }
    
    self.session.run(config)
  }

  @objc required dynamic init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FocusARView: FocusEntityDelegate {
    
    func enableObjectRemoval() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
        self.addGestureRecognizer(longPressGestureRecognizer)
        print("DEBUG: enableObjectRemoval loaded")
    }
    
    @objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        let location = recognizer.location(in: self)
        
        if let entity = self.entity(at: location) {
            if let anchorEntity = entity.anchor {
                anchorEntity.removeFromParent()
                callBack()
            }
         
        }
    }
    
    func toTrackingState() {
        print("tracking")
    }
    func toInitializingState() {
        print("initializing")
    }
}
