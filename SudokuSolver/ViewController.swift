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
    var solveSudoku: SudokuClass!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picButton.layer.cornerRadius = picButton.frame.size.width / 2
        picButton.clipsToBounds = true
        
        camBuffer = CameraBuffer()
        camBuffer.delegate = self
        
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
    
    func captured(image: UIImage) {
        // Setting up camera view
        imgView.image = image
    }
    
    @IBAction func takePictureOnTap(_ sender: Any) {
        // Make sure capturePhotoOutput is valid
        guard let capturePhotoOutput = camBuffer.capPhotoOutput else { return }
        
        // Get an instance of AVCapturePhotoSettings class
        let photoSettings = AVCapturePhotoSettings()
        
        // Set photo settings for our need
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .off
        
        // Call capturePhoto method by passing our photo settings and a delegate implementing AVCapturePhotoCaptureDelegate
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: camBuffer)
    }
}
