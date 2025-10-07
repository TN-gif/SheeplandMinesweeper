import { Cell } from '../model/Cell';

class NeighborStats {
  unrevealed: number;
  flagged: number;

  constructor(unrevealed: number, flagged: number) {
    this.unrevealed = unrevealed;
    this.flagged = flagged;
  }
}

/**
 * A simple, deterministic solver for Minesweeper.
 * It only applies the two most basic logical rules and does not perform any guessing.
 * This is used to verify if a generated board is solvable without luck.
 */
export class Solver {
  static solve(board: Cell[][], rows: number, cols: number, mineCount: number): boolean {
    const boardCopy: Cell[][] = JSON.parse(JSON.stringify(board));
    let movesMade: boolean = true;

    while (movesMade) {
      movesMade = false;

      for (let r: number = 0; r < rows; r++) {
        for (let c: number = 0; c < cols; c++) {
          const cell: Cell = boardCopy[r][c];
          if (!cell.isRevealed || cell.adjacentMines === 0) {
            continue;
          }

          const stats: NeighborStats = this.getNeighborStats(boardCopy, r, c, rows, cols);

          // Rule 1 (Chord): If flagged neighbors equals the cell's number, reveal the rest.
          if (stats.flagged === cell.adjacentMines) {
            if (this.revealNeighbors(boardCopy, r, c, rows, cols)) {
              movesMade = true;
            }
          }

          // Rule 2 (Flagging): If unrevealed neighbors equals the cell's number, flag them all.
          if (stats.unrevealed === cell.adjacentMines) {
            if (this.flagNeighbors(boardCopy, r, c, rows, cols)) {
              movesMade = true;
            }
          }
        }
      }
    }

    // Check if the board is solved by seeing if all non-mine cells are revealed.
    let revealedCount: number = 0;
    boardCopy.forEach((row: Cell[]) => row.forEach((cell: Cell) => {
      if (cell.isRevealed) {
        revealedCount++;
      }
    }));

    return revealedCount === (rows * cols - mineCount);
  }

  private static getNeighborStats(board: Cell[][], r: number, c: number, rows: number, cols: number): NeighborStats {
    let unrevealed: number = 0;
    let flagged: number = 0;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR: number = r + i;
        const newC: number = c + j;
        if (this.isValid(newR, newC, rows, cols)) {
          const neighbor: Cell = board[newR][newC];
          if (!neighbor.isRevealed) {
            unrevealed++;
            if (neighbor.isFlagged) {
              flagged++;
            }
          }
        }
      }
    }
    return new NeighborStats(unrevealed, flagged);
  }

  private static revealNeighbors(board: Cell[][], r: number, c: number, rows: number, cols: number): boolean {
    let changed: boolean = false;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR: number = r + i;
        const newC: number = c + j;
        if (this.isValid(newR, newC, rows, cols)) {
          const neighbor: Cell = board[newR][newC];
          if (!neighbor.isRevealed && !neighbor.isFlagged) {
            neighbor.isRevealed = true;
            changed = true;
          }
        }
      }
    }
    return changed;
  }

  private static flagNeighbors(board: Cell[][], r: number, c: number, rows: number, cols: number): boolean {
    let changed: boolean = false;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR: number = r + i;
        const newC: number = c + j;
        if (this.isValid(newR, newC, rows, cols)) {
          const neighbor: Cell = board[newR][newC];
          if (!neighbor.isRevealed && !neighbor.isFlagged) {
            neighbor.isFlagged = true;
            changed = true;
          }
        }
      }
    }
    return changed;
  }

  private static isValid(r: number, c: number, rows: number, cols: number): boolean {
    return r >= 0 && r < rows && c >= 0 && c < cols;
  }
}
