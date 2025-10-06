import { Cell } from '../model/Cell';

/**
 * A simple, deterministic solver for Minesweeper.
 * It only applies the two most basic logical rules and does not perform any guessing.
 * This is used to verify if a generated board is solvable without luck.
 */
export class Solver {
  static solve(board: Cell[][], rows: number, cols: number, mineCount: number): boolean {
    const boardCopy: Cell[][] = JSON.parse(JSON.stringify(board));
    let movesMade = true;

    while (movesMade) {
      movesMade = false;

      for (let r = 0; r < rows; r++) {
        for (let c = 0; c < cols; c++) {
          const cell = boardCopy[r][c];
          if (!cell.isRevealed || cell.adjacentMines === 0) {
            continue;
          }

          const { unrevealed, flagged } = this.getNeighborStats(boardCopy, r, c, rows, cols);

          // Rule 1 (Chord): If flagged neighbors equals the cell's number, reveal the rest.
          if (flagged === cell.adjacentMines) {
            if (this.revealNeighbors(boardCopy, r, c, rows, cols)) {
              movesMade = true;
            }
          }

          // Rule 2 (Flagging): If unrevealed neighbors equals the cell's number, flag them all.
          if (unrevealed === cell.adjacentMines) {
            if (this.flagNeighbors(boardCopy, r, c, rows, cols)) {
              movesMade = true;
            }
          }
        }
      }
    }

    // Check if the board is solved by seeing if all non-mine cells are revealed.
    let revealedCount = 0;
    boardCopy.forEach(row => row.forEach(cell => {
      if (cell.isRevealed) {
        revealedCount++;
      }
    }));

    return revealedCount === (rows * cols - mineCount);
  }

  private static getNeighborStats(board: Cell[][], r: number, c: number, rows: number, cols: number): { unrevealed: number, flagged: number } {
    let unrevealed = 0;
    let flagged = 0;
    for (let i = -1; i <= 1; i++) {
      for (let j = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR = r + i;
        const newC = c + j;
        if (this.isValid(newR, newC, rows, cols)) {
          const neighbor = board[newR][newC];
          if (!neighbor.isRevealed) {
            unrevealed++;
            if (neighbor.isFlagged) {
              flagged++;
            }
          }
        }
      }
    }
    return { unrevealed, flagged };
  }

  private static revealNeighbors(board: Cell[][], r: number, c: number, rows: number, cols: number): boolean {
    let changed = false;
    for (let i = -1; i <= 1; i++) {
      for (let j = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR = r + i;
        const newC = c + j;
        if (this.isValid(newR, newC, rows, cols)) {
          const neighbor = board[newR][newC];
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
    let changed = false;
    for (let i = -1; i <= 1; i++) {
      for (let j = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR = r + i;
        const newC = c + j;
        if (this.isValid(newR, newC, rows, cols)) {
          const neighbor = board[newR][newC];
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
