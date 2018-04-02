# Sudoku-Solver-iOS


## TODO
  - ~~~Use vision to detect rectangles~~~
  - ~~~Identify if the rectangles detected is a sudoku puzzle or not~~~
     - ~~~Check if it is a group of 9 rectangles?~~~
     - ~~~Check if its a group of 81 squares?~~~
  - ~~~Somewhere along the lines we might have to convert the photo to Black and White so MNIST can read it~~~
  - If it is, divide into 81 individual squares and run it through MNIST
  - Populate 2D array using MNIST
  - Run the solve algorithm to solve the sudoku
  - Add the numbers into the empty boxes somehow
