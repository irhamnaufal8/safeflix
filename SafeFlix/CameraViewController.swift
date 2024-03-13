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
    var isPhotoCaptured = false
    
    var faceDetectionRequest = VNDetectFaceLandmarksRequest()
    
    weak var delegate: CameraViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupVision()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.beginConfiguration()
        
        // Konfigurasi input kamera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: frontCamera),
              captureSession.canAddInput(input) else {
            fatalError("Unable to setup front camera input")
        }
        captureSession.addInput(input)
        
        // Konfigurasi output foto
        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else {
            fatalError("Unable to add photo output")
        }
        captureSession.addOutput(photoOutput)
        
        captureSession.commitConfiguration()
        setupVideoDataOutput()
        
        // Tampilkan preview layer
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
        guard !isPhotoCaptured, let observations = request.results as? [VNFaceObservation], !observations.isEmpty else { return }
        
        for face in observations {
            // Periksa apakah landmarks wajah yang diinginkan terdeteksi
            guard let landmarks = face.landmarks,
                    landmarks.leftEye != nil,
                    landmarks.rightEye != nil,
                    landmarks.outerLips != nil
            else {
                continue // Salah satu fitur wajah penting tidak terdeteksi
            }
            
            // Fitur wajah penting terdeteksi, ambil foto
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                let settings = AVCapturePhotoSettings()
                self.photoOutput.capturePhoto(with: settings, delegate: self)
                self.isPhotoCaptured = true
            }
            break // Hentikan loop setelah foto diambil
        }
    }
    
    func capturePhotoIfFaceDetected() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
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
}

extension CameraViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !isPhotoCaptured, !metadataObjects.isEmpty else { return }
        // Wajah terdeteksi, ambil foto
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // Delegate method untuk menerima foto yang telah ditangkap
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
