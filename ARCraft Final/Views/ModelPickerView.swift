//
//  ModelPickerView.swift
//  ModelPickerApp
//
//  Created by David Tsang on 3/1/2023.
//

import SwiftUI

struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                ForEach(0..<self.models.count, id: \.self) { index in
                    Button(action: {
                        withAnimation {
                            print("DEBUG: Selected model with name: \(self.models[index])")
                            
                            selectedModel = models[index]
                            
                            isPlacementEnabled = true
                        }
                    }) {
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
    
}

struct ModelPickerView_Previews: PreviewProvider {

    static var previews: some View {
        let models = getModelFilenames()
        
        ModelPickerView(isPlacementEnabled: .constant(false), selectedModel: .constant(models[0]), models: models)
    }
}
