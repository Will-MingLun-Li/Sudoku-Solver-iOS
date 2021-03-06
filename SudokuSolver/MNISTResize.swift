//
//  MNISTResize.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-04-02.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit

extension UIImage {
    
    // Resize the Image to be 28px by 28px since MNIST reads that the best
    func resize(to newSize: CGSize) -> UIImage? {
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // Convert to a pixel buffer to read
    func pixelBuffer() -> CVPixelBuffer? {
        var pixelBuffer: CVPixelBuffer? = nil
        
        let width = Int(self.size.width)
        let height = Int(self.size.height)
        
        CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_OneComponent8, nil, &pixelBuffer)
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue:0))
        
        let colorspace = CGColorSpaceCreateDeviceGray()
        let bitmapContext = CGContext(data: CVPixelBufferGetBaseAddress(pixelBuffer!), width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: colorspace, bitmapInfo: 0)!
        
        guard let cg = self.cgImage else {
            return nil
        }
        
        bitmapContext.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelBuffer
    }
}

