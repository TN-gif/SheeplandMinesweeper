import { Cell } from '../model/Cell';
import { Level } from '../model/Level';
import { adventureService } from '../services/AdventureService';
import { itemService } from '../services/ItemService';
import { achievementService } from '../services/AchievementService';

interface Coordinate {
  x: number;
  y: number;
}

@Observed
export class GameViewModel {
  rows: number = 10;
  cols: number = 10;
  mineCount: number = 15;
  board: Cell[][] = [];
  gameOver: boolean = false;
  gameWon: boolean = false;
  selectedItem: 'magnifying_glass' | 'iron_fist' | null = null;
  tempRevealedCell: Coordinate | null = null;

  constructor(level: Level | null = null) {
    if (level) {
      this.rows = level.rows;
      this.cols = level.cols;
      this.mineCount = level.mines;
    }
    this.initBoard();
    achievementService.init();
    adventureService.init();
    itemService.init();
  }

  initBoard(): void {
    // ... implementation ...
  }

  selectItem(itemId: 'magnifying_glass' | 'iron_fist'): void {
    if (this.selectedItem === itemId) {
      this.selectedItem = null;
    } else {
      this.selectedItem = itemId;
    }
  }

  revealCell(x: number, y: number, isAutoReveal: boolean = false): void {
    if (this.tempRevealedCell) {
      this.board[this.tempRevealedCell.x][this.tempRevealedCell.y].isRevealed = false;
      this.tempRevealedCell = null;
    }

    if (this.selectedItem) {
      this.useSelectedItem(x, y);
      return;
    }

    // ... (rest of the normal reveal logic)
  }

  flagCell(x: number, y: number): void {
      // ... implementation to flag a cell ...
  }


  private useSelectedItem(x: number, y: number): void {
    if (!this.selectedItem || !itemService.useItem(this.selectedItem)) {
      this.selectedItem = null;
      return;
    }

    const cell = this.board[x][y];

    switch (this.selectedItem) {
      case 'magnifying_glass':
        cell.isRevealed = true;
        const tempCell: Coordinate = { x, y };
        this.tempRevealedCell = tempCell;
        break;

      case 'iron_fist':
        if (cell.isMine) {
          cell.isMine = false;
          this.mineCount--;
          this.recalculateAdjacentMinesAround(x, y);
        }
        this.revealCell(x, y, true);
        break;
    }
    this.selectedItem = null;
  }

  private recalculateAdjacentMinesAround(x: number, y: number): void {
    for (let i = -1; i <= 1; i++) {
      for (let j = -1; j <= 1; j++) {
        const newX = x + i;
        const newY = y + j;
        if (this.isValid(newX, newY)) {
          this.calculateAdjacentMinesForCell(newX, newY);
        }
      }
    }
  }

  private isValid(x: number, y: number): boolean {
    return x >= 0 && x < this.rows && y >= 0 && y < this.cols;
  }

  private calculateAdjacentMinesForCell(x: number, y: number): void {
    // ... implementation ...
  }
}
