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
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var position = AVCaptureDevice.Position.back
    private let quality = AVCaptureSession.Preset.vga640x480
    private let captureSession = AVCaptureSession()
    private let context = CIContext()
    
    weak var delegate: CameraBufferDelegate?
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        do {
            //was var finalFormat = AVCaptureDeviceFormat()
            var finalFormat = captureDevice.activeFormat //I think this probably isn’t quite right. But are we maybe just initializing it to something with the intent of overriding it in the loop below?
            var maxFps: Double = 0
            let maxFpsDesired: Double = 30 // was zero, but was that intended?
            for vFormat in captureDevice.formats {
                var ranges      = (vFormat as AnyObject).videoSupportedFrameRateRanges as!  [AVFrameRateRange]
                let frameRates  = ranges[0]
                
                if frameRates.maxFrameRate >= maxFps && frameRates.maxFrameRate <= maxFpsDesired {
                    maxFps = frameRates.maxFrameRate
                    finalFormat = vFormat as! AVCaptureDevice.Format
                }
            }
            if maxFps != 0 {
                let timeValue = Int64(1200.0 / maxFps)
                let timeScale: Int32 = 1200
                try captureDevice.lockForConfiguration()
                captureDevice.activeFormat = finalFormat
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(timeValue, timeScale)
                captureDevice.activeVideoMaxFrameDuration = CMTimeMake(timeValue, timeScale)
                captureDevice.focusMode = AVCaptureDevice.FocusMode.autoFocus
                captureDevice.unlockForConfiguration()
            }
            print(maxFps)
        }
        catch {
            print("Something was wrong")
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
}
