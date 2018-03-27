//
//  ImageViewController.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-03-22.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit
import Vision

class ImageViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var analyzedImageView: UIImageView!
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var originalImage : UIImage?
    var imageToAnalyze : CIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = originalImage {
            analyzedImageView.image = availableImage
        }
    }
    
    lazy var rectangleBoxRequest: VNDetectRectanglesRequest = {
        return VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
    }()
    
    // MARK: Methods
    func imageController(originalImg: UIImage) {
        analyzedImageView.image = originalImg

        self.originalImage = originalImg
        let uiImage = originalImg
        guard let ciImage = CIImage(image: uiImage) else { fatalError("can't create CIImage from UIImage") }

        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: CGImagePropertyOrientation(rawValue: UInt32(Int32(uiImage.imageOrientation.rawValue)))!)

        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([self.rectangleBoxRequest])
            } catch {
                print(error)
            }
        }
    }
    
    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
        
        var toRect = CGRect()
        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y )
        toRect.origin.y  = toRect.origin.y -  toRect.size.height
        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
        
        return toRect
    }
    
    func CreateBoxView(withColor : UIColor) -> UIView {
        let view = UIView()
        view.layer.borderColor = withColor.cgColor
        view.layer.borderWidth = 2
        view.backgroundColor = UIColor.clear
        return view
    }
    
    func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRectangleObservation]
            else { print("unexpected result type from VNDetectRectanglesRequest")
                return
        }
        guard observations.first != nil else {
            return
        }
        print(self.analyzedImageView)
        // Show the pre-processed image
        DispatchQueue.main.async {
            for rect in observations
            {
                let view = self.CreateBoxView(withColor: UIColor.cyan)
                view.frame = self.transformRect(fromRect: rect.boundingBox, toViewRect: self.analyzedImageView)
                self.analyzedImageView.image = self.originalImage
                self.analyzedImageView.addSubview(view)
                self.analyzedImageView.isHidden = false
            }
        }
    }

}
