//
//  CollectionViewCell.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-04-09.
//  Copyright © 2018 Will Li. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var number: UITextField!
    
    override func awakeFromNib() {
        number.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        addDoneButtonOnNumpad()
    }
    
    func addDoneButtonOnNumpad() {
        let keypadToolbar: UIToolbar = UIToolbar()
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(UIView.endEditing(_:)))
        keypadToolbar.setItems([flexButton, doneButton], animated: true)
        keypadToolbar.sizeToFit()
        number.inputAccessoryView = keypadToolbar
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let index = number.tag
        if let text = number.text, !text.isEmpty {
            //parentVC.puzzle[index] = Int(text)!
            //parentVC.color[index] = false
        } else {
            //parentVC.puzzle[index] = -1
            //parentVC.color[index] = true
        }
    }
}

