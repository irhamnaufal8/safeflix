//
//  CameraViewController.swift
//  SafeFlix
//
//  Created by Irham Naufal on 13/03/24.
//

import AVFoundation
import UIKit
import Vision

protocol CameraViewControllerDelegate: NSObject {
    func didFinishTakingPhoto(_ image: UIImage)
}

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    var captureSession: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var frontCamera: AVCaptureDevice!
    var videoDataOutput: AVCaptureVideoDataOutput!
    var noFaceDetectedLabel: UILabel!
    var isPhotoCaptured = false
    
    var faceDetectionRequest = VNDetectFaceLandmarksRequest()
    
    weak var delegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupVision()
        setupNoFaceDetectedLabel()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera),
              captureSession.canAddInput(input) else {
            fatalError("Unable to setup front camera input")
        }
        captureSession.addInput(input)
        
        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            fatalError("Unable to add photo output")
        }
        captureSession.addOutput(photoOutput)
        
        captureSession.commitConfiguration()
        setupVideoDataOutput()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func setupVision() {
        faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: handleFaces)
    }
    
    func handleFaces(request: VNRequest, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let observations = request.results as? [VNFaceObservation],
                  !observations.isEmpty,
                  !self.isPhotoCaptured
            else {
                return
            }
            
            self.noFaceDetectedLabel.isHidden = true
            
            for face in observations {
                guard let landmarks = face.landmarks,
                      landmarks.leftEye != nil,
                      landmarks.rightEye != nil,
                      landmarks.outerLips != nil
                else {
                    continue
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
                    guard let self = self else { return }
                    self.capturePhotoIfFaceDetected()
                }
                break
            }
        }
    }
    
    func capturePhotoIfFaceDetected() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
        isPhotoCaptured = true
    }
    
    func setupVideoDataOutput() {
        videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA as UInt32]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
        } else {
            fatalError("Could not add video data output to the session")
        }
    }
    
    func setupNoFaceDetectedLabel() {
        noFaceDetectedLabel = UILabel()
        noFaceDetectedLabel.text = "No Face Detected"
        noFaceDetectedLabel.textColor = .black
        noFaceDetectedLabel.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        noFaceDetectedLabel.textAlignment = .center
        noFaceDetectedLabel.layer.cornerRadius = 10
        noFaceDetectedLabel.layer.masksToBounds = true
        noFaceDetectedLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noFaceDetectedLabel)

        NSLayoutConstraint.activate([
            noFaceDetectedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noFaceDetectedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noFaceDetectedLabel.widthAnchor.constraint(equalToConstant: 200),
            noFaceDetectedLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        noFaceDetectedLabel.isHidden = false
    }
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isPhotoCaptured, !metadataObjects.isEmpty else { return }
        capturePhotoIfFaceDetected()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            delegate?.didFinishTakingPhoto(image)
            captureSession.stopRunning()
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
        try? imageRequestHandler.perform([self.faceDetectionRequest])
    }
}
