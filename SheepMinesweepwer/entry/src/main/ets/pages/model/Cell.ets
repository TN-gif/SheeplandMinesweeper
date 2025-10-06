export class Cell {
  isMine: boolean = false;
  isRevealed: boolean = false;
  isFlagged: boolean = false;
  adjacentMines: number = 0;
  x: number;
  y: number;
  shake: boolean = false; // For game over animation

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}
