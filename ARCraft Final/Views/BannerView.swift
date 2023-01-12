//
//  BannerView.swift
//  ModelPickerApp
//
//  Created by David Tsang on 4/1/2023.
//

import SwiftUI

struct BannerView: View {
    @Binding var fadeInOut: Bool
    
    var body: some View {
        Text("Long Press Object To Remove")
            .onAppear() {
                withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    fadeInOut.toggle()
                }
            }.opacity(fadeInOut ? 0:1)
    }
}

//struct BannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        BannerView()
//    }
//}
