import { HexCell, HexUtils, AxialCoord } from '../model/HexUtils';
import { audioManager } from '../services/AudioManager';

@Observed
export class HexGameViewModel {
  // A map is better for sparse hex grids
  board: Map<string, HexCell> = new Map();
  // The radius of the hexagonal map (number of rings from the center)
  mapRadius: number = 4;
  mineCount: number = 12;
  gameOver: boolean = false;
  gameWon: boolean = false;
  isFirstClick: boolean = true;

  constructor() {
    this.initGame();
  }

  // Helper to create a key for the map from axial coordinates
  private coordToKey(coord: AxialCoord): string {
    return `${coord.q},${coord.r}`;
  }

  initGame(): void {
    this.board.clear();
    this.gameOver = false;
    this.gameWon = false;
    this.isFirstClick = true;

    // Create a hexagonal map shape
    for (let q: number = -this.mapRadius; q <= this.mapRadius; q++) {
      for (let r: number = -this.mapRadius; r <= this.mapRadius; r++) {
        const s: number = -q - r;
        if (s >= -this.mapRadius && s <= this.mapRadius) {
          const coord: AxialCoord = new AxialCoord(q, r);
          const key: string = this.coordToKey(coord);
          this.board.set(key, new HexCell(q, r));
        }
      }
    }

    // 不立即放置地雷，等待第一次点击
  }

  placeMines(firstClickQ: number, firstClickR: number): void {
    const keys: string[] = Array.from(this.board.keys());
    const firstClickCoord: AxialCoord = new AxialCoord(firstClickQ, firstClickR);
    const safeZone: Set<string> = new Set();
    
    // 第一次点击位置及其周围都是安全区
    safeZone.add(this.coordToKey(firstClickCoord));
    const neighbors: AxialCoord[] = HexUtils.getNeighbors(firstClickCoord);
    neighbors.forEach((neighbor: AxialCoord) => {
      safeZone.add(this.coordToKey(neighbor));
    });
    
    let minesPlaced: number = 0;
    while (minesPlaced < this.mineCount) {
      const randomIndex: number = Math.floor(Math.random() * keys.length);
      const randomKey: string = keys[randomIndex];
      const cell: HexCell | undefined = this.board.get(randomKey);

      if (cell && !cell.isMine && !safeZone.has(randomKey)) {
        cell.isMine = true;
        minesPlaced++;
      }
    }
  }

  calculateAdjacentMines(): void {
    for (const cell of this.board.values()) {
      if (cell.isMine) continue;
      const cellCoord: AxialCoord = new AxialCoord(cell.q, cell.r);
      const neighbors: AxialCoord[] = HexUtils.getNeighbors(cellCoord);
      let mineCount: number = 0;
      for (const neighborCoord of neighbors) {
        const neighborKey: string = this.coordToKey(neighborCoord);
        const neighborCell: HexCell | undefined = this.board.get(neighborKey);
        if (neighborCell && neighborCell.isMine) {
          mineCount++;
        }
      }
      cell.adjacentMines = mineCount;
    }
  }

  revealCell(q: number, r: number): void {
    // 第一次点击时才放置地雷
    if (this.isFirstClick) {
      this.placeMines(q, r);
      this.calculateAdjacentMines();
      this.isFirstClick = false;
    }

    const coord: AxialCoord = new AxialCoord(q, r);
    const key: string = this.coordToKey(coord);
    if (!this.board.has(key)) return;

    const cell: HexCell | undefined = this.board.get(key);
    if (!cell || cell.isRevealed || cell.isFlagged || this.gameOver) return;

    cell.isRevealed = true;

    if (cell.isMine) {
      this.gameOver = true;
      audioManager.playSound('lose');
      // 显示所有地雷
      this.revealAllMines();
      return;
    }

    if (cell.adjacentMines === 0) {
      // Flood fill for hex grid
      const neighbors: AxialCoord[] = HexUtils.getNeighbors(coord);
      neighbors.forEach((n: AxialCoord): void => this.revealCell(n.q, n.r));
    }
    this.checkWinCondition();
  }

  private revealAllMines(): void {
    this.board.forEach((cell: HexCell) => {
      if (cell.isMine) {
        cell.isRevealed = true;
      }
    });
  }

  flagCell(q: number, r: number): void {
    const coord: AxialCoord = new AxialCoord(q, r);
    const key: string = this.coordToKey(coord);
    const cell: HexCell | undefined = this.board.get(key);
    if (!cell || cell.isRevealed) return;
    cell.isFlagged = !cell.isFlagged;
  }

  checkWinCondition(): void {
    if (this.isFirstClick) return; // 第一次点击前不检查胜利条件
    
    const totalCells: number = this.board.size;
    let revealedCount: number = 0;
    this.board.forEach((cell: HexCell) => {
      if (cell.isRevealed) {
        revealedCount++;
      }
    });

    if (revealedCount === totalCells - this.mineCount) {
      this.gameWon = true;
      this.gameOver = true;
      audioManager.playSound('win');
    }
  }

  // 清理资源
  destroy(): void {
    this.board.clear();
    this.gameOver = false;
    this.gameWon = false;
  }
}
