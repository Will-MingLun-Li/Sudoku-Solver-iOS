//
//  BacktrackAlgorithm.swift
//  SudokuSolver
//
//  Created by Will Li on 2018-03-07.
//  Copyright © 2018 Will Li. All rights reserved.
//

class SudokuClass {
    
    // Mark is used to represent values that can potentially fill in a square, it must be between 1 and 9, if its not we default it to 1
    struct Mark {
        let value : Int
        
        init(_ value: Int) {
            assert(1 <= value && value <= 9, "Number must be between 1 and 9")
            
            switch value {
            case 1...9: self.value = value
            default: self.value = 1
            }
        }
    }
    
    // Square is used to represent each square on the board, filled ones have a number while empty ones have a value of 0
    enum Square: ExpressibleByIntegerLiteral {
        case Empty
        case Marked(Mark)
        
        // All values between 1 to 9 will be treated as a Mark, otherwise they will be empty
        init(integerLiteral value: IntegerLiteralType) {
            switch value {
            case 1...9: self = .Marked(Mark(value))
            default:    self = .Empty
            }
        }
        
        // Check if the square is empty
        var isEmpty: Bool {
            switch self {
            case .Empty:     return true
            case .Marked(_): return false
            }
        }
        
        // Check if the square is marked by a value
        func isMarked(_ value: Int) -> Bool {
            switch self {
            case .Marked(let mark): return mark.value == value
            case .Empty:            return false
            }
        }
    }
    
    // Declare our board as a 2D array
    typealias SudokuBoard = [[Square]]
    
    func SolveSudoku(_ s: SudokuBoard) -> SudokuBoard? {
        if let (row, col) = findUnassignedLocation(s) {
            for mark in 1...9 {
                if (!usedInRow(s, mark: mark, col: col) &&
                    !usedInCol(s, mark: mark, row: row) &&
                    !usedInBox(s, mark: mark, row: row, col: col)) {
                    
                    let newBoard = CopySudoku(s, mark: mark, row: row, col: col)
                    if let solution = SolveSudoku(newBoard) {
                        return solution
                    }
                }
            }
            
            return nil
        } else {
            return s
        }
    }
    
    // Make a copy of the board with a new mark value in it
    func CopySudoku(_ s: SudokuBoard, mark: Int, row: Int, col: Int) ->SudokuBoard {
        var newBoard = SudokuBoard(s)
        newBoard[row][col] = .Marked(Mark(mark))
        
        return newBoard
    }
    
    // Find unassigned blocks in the board
    func findUnassignedLocation(_ s: SudokuBoard) -> (Int, Int)? {
        for row in 0..<9 {
            for col in 0..<9 {
                if s[row][col].isEmpty { return (row, col) }
            }
        }
        
        return nil
    }
    
    // Check if a specific value is already used in a row
    func usedInRow(_ s: SudokuBoard, mark: Int, col: Int) -> Bool {
        for row in 0..<9 {
            if (s[row][col].isMarked(mark)) { return true }
        }
        
        return false
    }
    
    // Check if a specific value is already used in a column
    func usedInCol(_ s: SudokuBoard, mark: Int, row: Int) -> Bool {
        for col in 0..<9 {
            if (s[row][col].isMarked(mark)) { return true }
        }
        
        return false
    }
    
    // Check if a specific value is already used in a box
    func usedInBox(_ s: SudokuBoard, mark: Int, row: Int, col: Int) -> Bool {
        let boxRowStart = (row / 3) * 3
        let boxRowEnd = boxRowStart + 2
        let boxColStart = (col / 3) * 3
        let boxColEnd = boxColStart + 2
        
        for row in boxRowStart...boxRowEnd {
            for col in boxColStart...boxColEnd {
                if (s[row][col].isMarked(mark)) { return true }
            }
        }
        
        return false
    }
    
    // Print the board for testing purposes
    func printSudoku(_ s: SudokuBoard) {
        for row in s {
            for val in row {
                switch val {
                case .Empty:              print(".", terminator: "")
                case .Marked(let mark):   print(mark.value, terminator: "")
                }
            }
            print()
        }
    }
    
}

