# Sudoku-Solver-iOS

<p align="center"> <img src ="https://i.imgur.com/Z0WR31y.jpg" /> </p>

A simple Computer Vision iOS Sudoku Solver app that allow users to take a picture of a sudoku puzzle, then provide them with what it thinks the numbers are at what locations and solves it using the classic [backtracking algorithm](https://spin.atomicobject.com/2012/06/18/solving-sudoku-in-c-with-recursive-backtracking/).

---

The cursor on the screen indicates where the puzzle should be placed (The better it fits, the better the reading accuracy). When the camera is adjusted, simply tap to camera button and a grid will be presented.

![grid](https://i.imgur.com/5ls4jV2.jpg)
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
![keyboard](https://i.imgur.com/BrSwXtn.jpg)

The app will extract the grid from the picture taken and run it through some image processing functions to reduce noises and make certain features easier to read. Then it will divide the picture into 81 square pieces and read each number individually using a trained MNIST dataset. The reading is not perfect, the accuracy can go anywhere from 20% to 90% depending on lighting, angle, camera quality, font, etc. Which is why after the readings are done, users can actually edit the false values to make them right. 

<p align="center"> <img src ="https://i.imgur.com/JFD6Qo3.jpg" /> </p>

Afterwards simply press 'solve' and it will present the solution. (The values read are in blue while the solved values are in black).
