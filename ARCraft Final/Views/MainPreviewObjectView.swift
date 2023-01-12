//
//  MainVRView.swift
//  ModelPickerApp
//
//  Created by Eddie Chan on 5/1/2023.
//

import SwiftUI
import LazyCollectionView

struct MainPreviewObjectView: View {
    @Binding var models: [Model]
    let description = "Suscipit inceptos est felis purus aenean aliquet adipiscing diam venenatis, augue nibh duis neque aliquam tellus condimentum sagittis vivamus, cras ante etiam sit conubia elit."
    @State private var showingPreview = false
    @State var objectToPreview: String = "toy_biplane"
    
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
                        showingPreview.toggle()
                        DispatchQueue.main.async {
                            objectToPreview = models[index].name
                        }
                        
                        print("DEBUG: \(models[index].name)")
                    }) {
                        Image(uiImage: models[index].image)
                            .resizable()
                            .frame(height: 120)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    .overlay(
                        Circle()
                            .strokeBorder(.black, lineWidth: 0)
                            .frame(width: 35, height: 35)
                            .overlay(models[index].isDownloadedContent ? Image(systemName: "checkmark.icloud") : Image(systemName: "")
                                
                            )
                        , alignment: .topTrailing)
                    .buttonStyle(PlainButtonStyle())
                    .sheet(isPresented: $showingPreview) {
                        // Sheet content: the quick look view with a header bar containing
                        // a simple 'close' button that closes the sheet.
                        VStack {
                            // Top row: button, aligned left
                            HStack {
                                Button("Close") {
                                    // Toggle the preview display off again.
                                    // Swiping down (the system gesture to dismiss a sheet)
                                    // will cause SwiftUI to toggle our state property as well.
                                    self.showingPreview.toggle()
                                }
                                // The spacer fills the space following the button, in effect
                                // pushing the button to the leading edge of the view.
                                Spacer()
                            }
                            .padding()
                            ARQuickLookView(name: self.objectToPreview)
                            Divider()
                            Text(description)
                                .padding(50)
                        }
                    }
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

