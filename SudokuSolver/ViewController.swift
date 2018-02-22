//
//  ViewController.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-02-15.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CameraBufferDelegate {
    var camBuffer: CameraBuffer!
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
}
