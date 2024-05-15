//
//  AgePredictor.swift
//  SafeFlix
//
//  Created by Irham Naufal on 13/03/24.
//

import CoreML
import UIKit
import VideoToolbox
import Vision

class AgePredictor: ObservableObject {
    
    @Published var predictedAge: Int?
    
    func predictAge(_ image: UIImage) {
        do {
            print("Tapped")
            let model = try MobileNetV2_AgePrediction(configuration: MLModelConfiguration())
            
            guard let pixelBuffer = image.pixelBuffer() else { return }
            print("Buffered")
            
            let vnModel = try VNCoreMLModel(for: model.model)
            
            let request = VNCoreMLRequest(model: vnModel, completionHandler: { request, error in
                guard let results = request.results as? [VNCoreMLFeatureValueObservation],
                      let firstResult = results.first,
                      let multiArray = firstResult.featureValue.multiArrayValue else {
                    print("Failed to process results")
                    return
                }
                print("RESULTS: \(multiArray)")
                
                let age = multiArray[0].floatValue
                DispatchQueue.main.async {
                    self.predictedAge = Int(age)
                    print("Predicted Age: \(age)")
                }
            })
            
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
}
