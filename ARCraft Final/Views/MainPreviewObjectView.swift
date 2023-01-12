//
//  MainVRView.swift
//  ModelPickerApp
//
//  Created by David Tsang on 5/1/2023.
//

import SwiftUI
import LazyCollectionView

struct MainPreviewObjectView: View {
    @Binding var models: [Model]
    
    var threeColumnGrid = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack (alignment: .top) {
            Text("Object List")
                .font(.title)
        }
        
        ScrollView {
            LazyVGrid(columns: threeColumnGrid) {
                // Display the item
                
                ForEach(0..<models.count, id: \.self) { index in
                    Button(action: {
                 
                    
                        print("DEBUG: \(models[index].name)")
                    }) {
                        Image(uiImage: models[index].image)
                            .resizable()
                            .frame(height: 120)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())

                }
            }
        }.preferredColorScheme(.light)
        
    }
}
struct MainPreviewObjectView_Previews : PreviewProvider {
    static var previews: some View {
        let models = getModelFilenames()
        
        MainPreviewObjectView(models: .constant(models))
    }
}

