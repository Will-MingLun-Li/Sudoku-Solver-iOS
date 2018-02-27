//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-02-15.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, CameraBufferDelegate {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var picButton: UIButton!
    
    var camBuffer: CameraBuffer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picButton.layer.cornerRadius = picButton.frame.size.width / 2
        picButton.clipsToBounds = true
        
        camBuffer = CameraBuffer()
        camBuffer.delegate = self
    }
    
    func captured(image: UIImage) {
        imgView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePictureOnTap(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = camBuffer.capPhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: camBuffer)
    }
}
