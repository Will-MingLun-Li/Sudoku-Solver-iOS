//
//  cameraBuffer.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-02-22.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraBufferDelegate: class {
    func captured(image: UIImage)
}

class CameraBuffer: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    // Initialise some variables
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    var capPhotoOutput: AVCapturePhotoOutput?
    
    weak var delegate: CameraBufferDelegate?
    
    override init() {
        super.init()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    private func configureSession() {
        // Set up the camera to receive camera preview
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        // Setup the output so pictures can be taken
        capPhotoOutput = AVCapturePhotoOutput()
        capPhotoOutput?.isHighResolutionCaptureEnabled = true
        guard captureSession.canAddOutput(capPhotoOutput!) else { return }
        captureSession.addOutput(capPhotoOutput!)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        connection.videoOrientation = .portrait
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        //self.imageDelegate?.analyzed(originalImg: lolimage)
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
}

extension CameraBuffer : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }

        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }

        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData, scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            //self.imageDelegate?.analyzed(originalImg: image)
            //imageVC.originalImage = image
            //imageVC.imageController(originalImg: image)
        }
    }
}


