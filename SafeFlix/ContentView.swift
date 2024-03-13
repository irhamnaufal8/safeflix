//
//  ContentView.swift
//  SafeFlix
//
//  Created by Irham Naufal on 13/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @State var showCamera = false
    @State private var image: UIImage? = UIImage(named: "harry")
    @ObservedObject private var predictor = AgePredictor()
    
    var body: some View {
        VStack(spacing: 32) {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            
            VStack {
                Text("Predicted Age:")
                
                Text(String(describing: predictor.predictedAge))
                    .font(.largeTitle)
            }
            
            HStack {
                Button {
                    showCamera = true
                } label: {
                    Text("Take a Photo")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                }
                .buttonStyle(.bordered)
                
                Button {
                    if let image {
                        predictor.predictAge(image)
                    }
                } label: {
                    Text("Predict")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onChange(of: image, { _, newValue in
            predictor.predictedAge = nil
            guard let image = newValue else { return }
            predictor.predictAge(image)
        })
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $image) {
                showCamera = false
            }
        }
    }
}

#Preview {
    ContentView()
}
