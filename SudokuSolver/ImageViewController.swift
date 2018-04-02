//
//  ImageViewController.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-03-22.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit
import Vision
import GPUImage

class ImageViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var analyzedImageView: UIImageView!
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var originalImage : UIImage?
    var noirImage : UIImage?
    var thresholdImage : UIImage?
    
    let threshold = AdaptiveThreshold()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = originalImage {
            threshold.blurRadiusInPixels = 4
            noirImage = availableImage.noir?.filterWithPipeline{input, output in
                input --> threshold --> ColorInversion() --> output
            }
            thresholdImage = UIImage(cgImage: (noirImage?.cgImage!)!, scale: (noirImage?.scale)!, orientation: .right)
        
            imageController(originalImg: thresholdImage!)
        }
    }
    
    lazy var rectangleBoxRequest: VNDetectRectanglesRequest = {
        let rectRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
        rectRequest.minimumAspectRatio = 0.3
        rectRequest.maximumObservations = 0
        return rectRequest
    }()

    // MARK: Methods
    func imageController(originalImg: UIImage) {
        let uiImage = originalImg
        guard let ciImage = CIImage(image: uiImage) else { fatalError("can't create CIImage from UIImage") }

        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .right)

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
        guard let observations = request.results as? [VNRectangleObservation] else {
            print("unexpected result type from VNDetectRectanglesRequest")
            return
        }
        guard observations.first != nil else {
            return
        }

        // Show the pre-processed image
        DispatchQueue.main.async {
            self.analyzedImageView.subviews.forEach({ (s) in
                s.removeFromSuperview()
            })
            for rect in observations {
                let view = self.CreateBoxView(withColor: UIColor.cyan)
                view.frame = self.transformRect(fromRect: rect.boundingBox, toViewRect: self.analyzedImageView)
                self.analyzedImageView.image = self.thresholdImage
                self.analyzedImageView.addSubview(view)
            }
        }
    }

}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)

        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: .right)
        }
        return nil
    }
}
