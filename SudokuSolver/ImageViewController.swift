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

class ImageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Variables
    var originalImage : UIImage?
    var thresholdImage : UIImage?
    
    var value = [Int]()
    var color = [Bool]()
    
    var screenSize : CGRect!
    var screenWidth : CGFloat!
    var screenHeight : CGFloat!
    
    // MARK: Class
    var sudokuClass : SudokuClass!
    var sudokuBoard : SudokuClass.SudokuBoard = [[SudokuClass.Square]](repeating: [SudokuClass.Square](repeating: 0, count: 9), count: 9)
    
    // MARK: Image Enhancement for Noise Cancellation
    let threshold = AdaptiveThreshold()
    let inversion = ColorInversion()
    let size = CGSize(width: 28, height: 28)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sudokuClass = SudokuClass()
        
        // Applying Image Enhancements for easier MNIST reading
        if let availableImage = originalImage {
            threshold.blurRadiusInPixels = 4
            let noirImage = availableImage.noir?.filterWithPipeline{input, output in
                input --> threshold --> inversion --> output
            }
            thresholdImage = UIImage(cgImage: (noirImage?.cgImage!)!, scale: (noirImage?.scale)!, orientation: .right)
        
            sudokuController()
            //imageController(originalImg: thresholdImage!)
        }
        
        // Configuration to set up the Sudoku Board grid
        screenSize = self.view.frame
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        
        let topInset = (collectionView.frame.size.height - screenWidth) / 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 9, height: screenWidth / 9)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        
        // Add frames for the puzzle
        for row in 0...2 {
            for col in 0...2 {
                let layer = CALayer()
                let x = CGFloat(col) * screenWidth / 3
                let y = CGFloat(row) * screenWidth / 3 + topInset
                layer.frame = CGRect(x: x, y: y, width: screenWidth / 3, height: screenWidth / 3)
                layer.borderWidth = 1.5
                collectionView.layer.addSublayer(layer)
            }
        }
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: topInset, width: screenWidth, height: screenWidth)
        layer.borderWidth = 3
        collectionView.layer.addSublayer(layer)
        
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 81
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: screenWidth / 9, height: screenWidth / 9);
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.number.tag = indexPath.row

        cell.number.textColor = UIColor.black
        if (color[indexPath.row]) {
            cell.number.textColor = UIColor.blue
        } else {
            cell.number.textColor = UIColor.black
        }

        let digit = value[indexPath.row]
        if digit != 0 {
            cell.number.text = String(digit)
        }

        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 1

        return cell
    }
    
    // Populate the 2D array with MNIST Readings
    func sudokuController() {
        var toRect = CGRect()
        toRect.size = CGSize(width: 715.0, height: 715.0)
        toRect.origin = CGPoint(x: 455.0, y: 180.0)
        
        // Cropping out the Sudoku Puzzle so we can use it to crop out the pieces easier
        let croppedCGImage = (thresholdImage!.cgImage?.cropping(to: toRect))!
        
        var piece = CGRect()
        piece.size = CGSize(width: 70, height: 70)
        
        // Crop out the individual pieces and populating out Board after reading them using MNIST
        for xPoint in 0..<9 {
            for yPoint in (0..<9).reversed() {
                piece.origin = CGPoint(x: (CGFloat(xPoint) * 80.0) + 8.0, y: (CGFloat(yPoint) * 80.0) + 5.0)
                
                let CGSquare = (croppedCGImage.cropping(to: piece))!
                var confidenceFlag = false
                guard let square = UIImage(cgImage: CGSquare, scale: 1.0, orientation: .right).resize(to: size) else { fatalError("Cannot retrieve square pieces") }
                guard let result = try? mnistCNN().prediction(image: square.pixelBuffer()!) else { fatalError("Cannot identify square pieces") }
                
                for (_, confidence) in result.output {
                    if (confidence > 0.6) {
                        confidenceFlag = true
                        break
                    }
                }
                if (confidenceFlag == true) {
                    sudokuBoard[xPoint][8 - yPoint] = SudokuClass.Square(integerLiteral: Int(result.classLabel)!)
                    value.append(Int(result.classLabel)!)
                    color.append(true)
                } else {
                    sudokuBoard[xPoint][8 - yPoint] = SudokuClass.Square(integerLiteral: 0)
                    value.append(0)
                    color.append(false)
                }
            }
        }
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize!.height, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size

        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: -keyboardSize!.height, right: 0)
        collectionView.contentInset = contentInsets
        collectionView.scrollIndicatorInsets = contentInsets
    }

    
// The commented out code are for Swift's Vision library, for some reason the size for CG image and CGRect doesn't align, so going for an easier solution for now

//    lazy var rectangleBoxRequest: VNDetectRectanglesRequest = {
//        let rectRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
//        rectRequest.minimumAspectRatio = 0.3
//        rectRequest.maximumObservations = 0
//        return rectRequest
//    }()
//
//    // MARK: Methods
//    func imageController(originalImg: UIImage) {
//        let uiImage = originalImg
//        guard let ciImage = CIImage(image: uiImage) else { fatalError("can't create CIImage from UIImage") }
//
//        let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .right)
//
//        DispatchQueue.global(qos: .userInteractive).async {
//            do {
//                try handler.perform([self.rectangleBoxRequest])
//            } catch {
//                print(error)
//            }
//        }
//    }
//
//    func transformRect(fromRect: CGRect , toViewRect :UIView) -> CGRect {
//        var toRect = CGRect()
//        toRect.size.width = fromRect.size.width * toViewRect.frame.size.width
//        toRect.size.height = fromRect.size.height * toViewRect.frame.size.height
//        toRect.origin.y =  (toViewRect.frame.height) - (toViewRect.frame.height * fromRect.origin.y)
//        toRect.origin.y  = toRect.origin.y - toRect.size.height
//        toRect.origin.x =  fromRect.origin.x * toViewRect.frame.size.width
//
//        return toRect
//    }
//
//    func CreateBoxView(withColor : UIColor) -> UIView {
//        let view = UIView()
//        view.layer.borderColor = withColor.cgColor
//        view.layer.borderWidth = 2
//        view.backgroundColor = UIColor.clear
//        return view
//    }
//
//    func handleRectangles(request: VNRequest, error: Error?) {
//        guard let observations = request.results as? [VNRectangleObservation] else {
//            print("unexpected result type from VNDetectRectanglesRequest")
//            return
//        }
//        guard observations.first != nil else {
//            return
//        }
//
//        // Show the pre-processed image
//        DispatchQueue.main.async {
//            self.analyzedImageView.subviews.forEach({ (s) in
//                s.removeFromSuperview()
//            })
//            for rect in observations {
//                let view = self.CreateBoxView(withColor: UIColor.cyan)
//                view.frame = self.transformRect(fromRect: rect.boundingBox, toViewRect: self.analyzedImageView)
//
//                self.analyzedImageView.image = self.thresholdImage
//                self.analyzedImageView.addSubview(view)
//            }
//        }
//    }

}

// Convert the image to black and white
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
