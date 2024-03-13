//
//  CameraView.swift
//  SafeFlix
//
//  Created by Irham Naufal on 13/03/24.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onPhotoCaptured: () -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func didFinishTakingPhoto(_ image: UIImage) {
            print("FINISHED TAKING PHOTO")
            parent.image = image
            DispatchQueue.main.async {
                self.parent.onPhotoCaptured()
            }
        }
    }
}
