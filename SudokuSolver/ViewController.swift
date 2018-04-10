//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-02-15.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var picButton: UIButton!
    @IBOutlet weak var scannerImg: UIImageView!
    @IBOutlet weak var LoadingLabel: UIActivityIndicatorView!
    
    var solveSudoku: SudokuClass!
    
    // MARK: Camera Session Variables
    let captureSession = AVCaptureSession()
    var previewLayer : CALayer!
    var captureDevice : AVCaptureDevice!
    
    var takePhoto = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Modifying the picture button to make it circular
        picButton.layer.cornerRadius = picButton.frame.size.width / 2
        picButton.clipsToBounds = true
        
        solveSudoku = SudokuClass()
        
        /* let example: SudokuClass.SudokuBoard = [
            [5, 3, 0,  0, 7, 0,  0, 0, 0],
            [6, 0, 0,  1, 9, 5,  0, 0, 0],
            [0, 9, 8,  0, 0, 0,  0, 6, 0],
            
            [8, 0, 0,  0, 6, 0,  0, 0, 3],
            [4, 0, 0,  8, 0, 3,  0, 0, 1],
            [7, 0, 0,  0, 2, 0,  0, 0, 6],
            
            [0, 6, 0,  0, 0, 0,  2, 8, 0],
            [0, 0, 0,  4, 1, 9,  0, 0, 5],
            [0, 0, 0,  0, 8, 0,  0, 7, 0],
        ]
        
        print("\nPuzzle:")
        solveSudoku.printSudoku(example)
        if let solutionForExample = solveSudoku.SolveSudoku(example) {
            print("\nSolution:")
            solveSudoku.printSudoku(solutionForExample)
        }
        else {
            print("No solution")
        } */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareCamera()
    }
    
    // Prepare the camera, set up the config for the camera input
    func prepareCamera() {
        captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let layer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = layer
        self.view.layer.addSublayer(self.previewLayer)
        self.view.bringSubview(toFront: picButton)
        self.view.bringSubview(toFront: scannerImg)
        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
    
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
    
        dataOutput.alwaysDiscardsLateVideoFrames = true
    
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
    
        captureSession.commitConfiguration()
    
        let queue = DispatchQueue(label: "session queue")
        dataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)
    }

    @IBAction func takePictureOnTap(_ sender: Any) {
        // Start the loading animation and use the boolean to indicate that a capture has started
        takePhoto = true
        LoadingLabel.startAnimating()
        view.addSubview(LoadingLabel)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // Uses the takePhoto boolean value to determine when a photo can be taken
        if takePhoto {
            // Reset takePhoto boolean
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                let photoVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
                photoVC.originalImage = image
                
                DispatchQueue.main.async {
                    self.present(photoVC, animated: true, completion: {
                        self.stopCaptureSession()
                        self.LoadingLabel.stopAnimating()
                    })
                }
            }
        }
    }
    
    // Retrieve the current buffer to get the image when the take picture button is pressed
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        
        return nil
    }
    
    // Stop the capturing session once a picture has already been taken
    func stopCaptureSession() {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
}
