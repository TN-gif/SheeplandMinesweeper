import { Cell } from '../model/Cell';
import { Level } from '../model/Level';
import { adventureService } from '../services/AdventureService';
import { itemService } from '../services/ItemService';
import { achievementService } from '../services/AchievementService';
import { audioManager } from '../services/AudioManager';
import common from '@ohos.app.ability.common';

class Coordinate {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

@Observed
export class GameViewModel {
  rows: number = 10;
  cols: number = 10;
  mineCount: number = 15;
  board: Cell[][] = [];
  gameOver: boolean = false;
  gameWon: boolean = false;
  selectedItem: 'magnifying_glass' | null = null;
  tempRevealedCell: Coordinate | null = null;
  
  // 计时器相关
  startTime: number = 0;
  elapsedTime: number = 0;
  timerInterval: number | null = null;
  
  // 第一次点击保护
  isFirstClick: boolean = true;

  constructor(level: Level | null = null, context?: common.UIAbilityContext) {
    if (level) {
      this.rows = level.rows;
      this.cols = level.cols;
      this.mineCount = level.mines;
    }
    this.initBoard();
    // Services will be initialized from the main page with context
    if (context) {
      achievementService.init(context);
      adventureService.init(context);
      itemService.init(context);
    }
  }

  initBoard(): void {
    this.board = [];
    this.gameOver = false;
    this.gameWon = false;
    this.elapsedTime = 0;
    this.startTime = 0;
    this.isFirstClick = true;
    this.stopTimer();
    
    // 创建空白棋盘（不放置地雷，等待第一次点击）
    for (let i: number = 0; i < this.rows; i++) {
      const row: Cell[] = [];
      for (let j: number = 0; j < this.cols; j++) {
        row.push(new Cell(i, j));
      }
      this.board.push(row);
    }
  }

  private placeMines(firstClickX: number, firstClickY: number): void {
    let minesPlaced: number = 0;
    while (minesPlaced < this.mineCount) {
      const x: number = Math.floor(Math.random() * this.rows);
      const y: number = Math.floor(Math.random() * this.cols);
      
      // 确保第一次点击的位置和周围8格不是地雷
      const isSafeZone: boolean = Math.abs(x - firstClickX) <= 1 && Math.abs(y - firstClickY) <= 1;
      
      if (!this.board[x][y].isMine && !isSafeZone) {
        this.board[x][y].isMine = true;
        minesPlaced++;
      }
    }
  }

  private calculateAdjacentMines(): void {
    for (let i: number = 0; i < this.rows; i++) {
      for (let j: number = 0; j < this.cols; j++) {
        this.calculateAdjacentMinesForCell(i, j);
      }
    }
  }

  selectItem(itemId: 'magnifying_glass'): void {
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

    if (!this.isValid(x, y) || this.gameOver) {
      return;
    }

    const cell: Cell = this.board[x][y];
    
    if (cell.isRevealed || cell.isFlagged) {
      return;
    }

    // 第一次点击时生成地雷（确保第一次点击安全）
    if (this.isFirstClick) {
      this.isFirstClick = false;
      this.placeMines(x, y);
      this.calculateAdjacentMines();
      // 开始计时器
      this.startTimer();
    }

    cell.isRevealed = true;

    // 如果是地雷，游戏失败
    if (cell.isMine) {
      this.gameOver = true;
      this.gameWon = false;
      this.stopTimer();
      this.revealAllMines();
      // 播放失败音效
      audioManager.playSound('lose');
      return;
    }

    // 播放点击音效和触觉反馈
    if (!isAutoReveal) {
      audioManager.playSound('click');
    }

    // 如果周围没有地雷，递归翻开周围的格子
    if (cell.adjacentMines === 0) {
      for (let i: number = -1; i <= 1; i++) {
        for (let j: number = -1; j <= 1; j++) {
          if (i === 0 && j === 0) continue;
          this.revealCell(x + i, y + j, true);
        }
      }
    }

    // 检查是否获胜
    this.checkWinCondition();
  }

  private revealAllMines(): void {
    for (let i: number = 0; i < this.rows; i++) {
      for (let j: number = 0; j < this.cols; j++) {
        const cell: Cell = this.board[i][j];
        if (cell.isMine) {
          cell.isRevealed = true;
          cell.shake = true;
        }
      }
    }
  }

  private checkWinCondition(): void {
    let revealedCount: number = 0;
    let totalCells: number = this.rows * this.cols;

    for (let i: number = 0; i < this.rows; i++) {
      for (let j: number = 0; j < this.cols; j++) {
        if (this.board[i][j].isRevealed) {
          revealedCount++;
        }
      }
    }

    if (revealedCount === totalCells - this.mineCount) {
      this.gameOver = true;
      this.gameWon = true;
      this.stopTimer();
      // 播放胜利音效
      audioManager.playSound('win');
      // 记录胜利
      achievementService.recordGameWin(this.elapsedTime, true);
    }
  }

  flagCell(x: number, y: number): void {
    if (!this.isValid(x, y) || this.gameOver) {
      return;
    }

    const cell: Cell = this.board[x][y];
    
    if (!cell.isRevealed) {
      cell.isFlagged = !cell.isFlagged;
      // 播放插旗音效和触觉反馈
      if (cell.isFlagged) {
        audioManager.playSound('flag');
      }
    }
  }

  // 和弦操作：当周围已插旗数等于数字时，自动翻开周围所有未插旗的格子
  chordCell(x: number, y: number): void {
    if (!this.isValid(x, y) || this.gameOver) {
      return;
    }

    const cell: Cell = this.board[x][y];
    
    // 只对已翻开且有数字的格子有效
    if (!cell.isRevealed || cell.isMine || cell.adjacentMines === 0) {
      return;
    }

    // 计算周围已插旗的数量
    let flagCount: number = 0;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newX: number = x + i;
        const newY: number = y + j;
        if (this.isValid(newX, newY) && this.board[newX][newY].isFlagged) {
          flagCount++;
        }
      }
    }

    // 如果周围旗子数量等于数字，翻开周围所有未插旗的格子
    if (flagCount === cell.adjacentMines) {
      for (let i: number = -1; i <= 1; i++) {
        for (let j: number = -1; j <= 1; j++) {
          if (i === 0 && j === 0) continue;
          const newX: number = x + i;
          const newY: number = y + j;
          if (this.isValid(newX, newY) && !this.board[newX][newY].isFlagged) {
            this.revealCell(newX, newY);
          }
        }
      }
    }
  }


  private useSelectedItem(x: number, y: number): void {
    if (!this.selectedItem) {
      return;
    }

    if (!this.isValid(x, y) || this.gameOver) {
      this.selectedItem = null;
      return;
    }

    const cell = this.board[x][y];
    
    if (cell.isRevealed) {
      // 已翻开的格子不能使用道具
      this.selectedItem = null;
      return;
    }

    // 第一次点击时生成地雷（确保第一次点击安全）
    if (this.isFirstClick) {
      this.isFirstClick = false;
      this.placeMines(x, y);
      this.calculateAdjacentMines();
      // 开始计时器
      this.startTimer();
    }

    // 保存道具类型
    const itemType = this.selectedItem;
    
    // 尝试消耗道具
    const itemUsed = itemService.useItem(itemType);
    
    if (!itemUsed) {
      // 道具数量不足，无法使用
      this.selectedItem = null;
      return;
    }

    // 清空选中状态
    this.selectedItem = null;

    // 放大镜：临时显示格子状态1.5秒
    cell.isRevealed = true;
    this.tempRevealedCell = new Coordinate(x, y);
    setTimeout(() => {
      if (this.tempRevealedCell) {
        this.board[this.tempRevealedCell.x][this.tempRevealedCell.y].isRevealed = false;
        this.tempRevealedCell = null;
      }
    }, 1500);
    audioManager.playSound('click');
  }

  private isValid(x: number, y: number): boolean {
    return x >= 0 && x < this.rows && y >= 0 && y < this.cols;
  }

  private calculateAdjacentMinesForCell(x: number, y: number): void {
    if (!this.isValid(x, y)) {
      return;
    }

    const cell: Cell = this.board[x][y];
    if (cell.isMine) {
      return;
    }

    let count: number = 0;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newX: number = x + i;
        const newY: number = y + j;
        if (this.isValid(newX, newY) && this.board[newX][newY].isMine) {
          count++;
        }
      }
    }
    cell.adjacentMines = count;
  }

  // 计时器方法
  private startTimer(): void {
    this.startTime = Date.now();
    this.timerInterval = setInterval(() => {
      this.elapsedTime = Math.floor((Date.now() - this.startTime) / 1000);
    }, 1000);
  }

  private stopTimer(): void {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }
  }

  getFormattedTime(): string {
    const minutes = Math.floor(this.elapsedTime / 60);
    const seconds = this.elapsedTime % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  // 获取剩余地雷数量
  getMinesRemaining(): number {
    let flagCount = 0;
    for (let i = 0; i < this.rows; i++) {
      for (let j = 0; j < this.cols; j++) {
        if (this.board[i][j].isFlagged) {
          flagCount++;
        }
      }
    }
    return this.mineCount - flagCount;
  }

  // 清理资源
  destroy(): void {
    this.stopTimer();
    this.selectedItem = null;
    this.tempRevealedCell = null;
  }
}
