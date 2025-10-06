import { Cell } from './model/Cell';
// ... other imports
import { adventureService } from '../services/AdventureService';
import { itemService, Item } from '../services/ItemService'; // Import item service and model

@Observed
export class GameViewModel {
  // ... (existing properties)
  selectedItem: 'magnifying_glass' | 'iron_fist' | null = null;
  tempRevealedCell: { x: number, y: number } | null = null; // For the magnifying glass

  constructor() {
    this.initBoard();
    achievementService.init();
    adventureService.init();
    itemService.init(); // Initialize the item service
  }

  selectItem(itemId: 'magnifying_glass' | 'iron_fist') {
    // Toggle selection
    if (this.selectedItem === itemId) {
      this.selectedItem = null;
    } else {
      this.selectedItem = itemId;
    }
  }

  revealCell(x: number, y: number, isAutoReveal: boolean = false) {
    if (this.tempRevealedCell) {
      // Hide the temporary reveal from the magnifying glass
      this.board[this.tempRevealedCell.x][this.tempRevealedCell.y].isRevealed = false;
      this.tempRevealedCell = null;
    }

    // Check if an item is selected and use it
    if (this.selectedItem) {
      this.useSelectedItem(x, y);
      return;
    }

    // ... (rest of the normal reveal logic)
  }

  private useSelectedItem(x: number, y: number) {
    if (!itemService.useItem(this.selectedItem!)) {
      this.selectedItem = null;
      return; // Item could not be used
    }

    const cell = this.board[x][y];

    switch (this.selectedItem) {
      case 'magnifying_glass':
        // Safely reveal the cell temporarily
        cell.isRevealed = true;
        this.tempRevealedCell = { x, y };
        break;

      case 'iron_fist':
        // Safely reveal the cell, even if it's a mine.
        // If it's a mine, we need to "disarm" it.
        if (cell.isMine) {
          cell.isMine = false;
          this.mineCount--; // One less mine to worry about
          // We need to recalculate adjacent numbers for neighbors
          this.recalculateAdjacentMinesAround(x, y);
        }
        this.revealCell(x, y, true); // Use normal reveal for flood fill
        break;
    }
    this.selectedItem = null; // Deselect after use
  }

  private recalculateAdjacentMinesAround(x: number, y: number) {
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
}
