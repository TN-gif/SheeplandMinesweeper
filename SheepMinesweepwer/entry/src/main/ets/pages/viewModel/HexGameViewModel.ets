import { HexCell, HexUtils, AxialCoord } from '../model/HexUtils';

@Observed
export class HexGameViewModel {
  // A map is better for sparse hex grids
  board: Map<string, HexCell> = new Map();
  // The radius of the hexagonal map (number of rings from the center)
  mapRadius: number = 4;
  mineCount: number = 10;
  gameOver: boolean = false;
  gameWon: boolean = false;

  constructor() {
    this.initGame();
  }

  // Helper to create a key for the map from axial coordinates
  private coordToKey(coord: AxialCoord): string {
    return `${coord.q},${coord.r}`;
  }

  initGame() {
    this.board.clear();
    this.gameOver = false;
    this.gameWon = false;

    // Create a hexagonal map shape
    for (let q = -this.mapRadius; q <= this.mapRadius; q++) {
      for (let r = -this.mapRadius; r <= this.mapRadius; r++) {
        const s = -q - r;
        if (s >= -this.mapRadius && s <= this.mapRadius) {
          const key = this.coordToKey({ q, r });
          this.board.set(key, new HexCell(q, r));
        }
      }
    }

    this.placeMines();
    this.calculateAdjacentMines();
  }

  placeMines() {
    const keys = Array.from(this.board.keys());
    let minesPlaced = 0;
    while (minesPlaced < this.mineCount) {
      const randomIndex = Math.floor(Math.random() * keys.length);
      const randomKey = keys[randomIndex];
      const cell = this.board.get(randomKey)!;

      if (!cell.isMine) {
        cell.isMine = true;
        minesPlaced++;
      }
    }
  }

  calculateAdjacentMines() {
    for (const cell of this.board.values()) {
      if (cell.isMine) continue;
      const neighbors = HexUtils.getNeighbors({ q: cell.q, r: cell.r });
      let mineCount = 0;
      for (const neighborCoord of neighbors) {
        const neighborKey = this.coordToKey(neighborCoord);
        if (this.board.has(neighborKey) && this.board.get(neighborKey)!.isMine) {
          mineCount++;
        }
      }
      cell.adjacentMines = mineCount;
    }
  }

  revealCell(q: number, r: number) {
    const key = this.coordToKey({ q, r });
    if (!this.board.has(key)) return;

    const cell = this.board.get(key)!;
    if (cell.isRevealed || cell.isFlagged || this.gameOver) return;

    cell.isRevealed = true;

    if (cell.isMine) {
      this.gameOver = true;
      return;
    }

    if (cell.adjacentMines === 0) {
      // Flood fill for hex grid
      const neighbors = HexUtils.getNeighbors({ q, r });
      neighbors.forEach(n => this.revealCell(n.q, n.r));
    }
    this.checkWinCondition();
  }

  flagCell(q: number, r: number) {
    const key = this.coordToKey({ q, r });
    if (!this.board.has(key) || this.board.get(key)!.isRevealed) return;
    const cell = this.board.get(key)!;
    cell.isFlagged = !cell.isFlagged;
  }

  checkWinCondition() {
    const totalCells = this.board.size;
    let revealedCount = 0;
    this.board.forEach(cell => {
      if (cell.isRevealed) {
        revealedCount++;
      }
    });

    if (revealedCount === totalCells - this.mineCount) {
      this.gameWon = true;
      this.gameOver = true;
    }
  }
}
