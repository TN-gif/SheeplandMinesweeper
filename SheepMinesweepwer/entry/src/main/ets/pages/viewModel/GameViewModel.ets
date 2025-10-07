import { Cell } from '../model/Cell';
import { Level } from '../model/Level';
import { adventureService } from '../services/AdventureService';
import { itemService } from '../services/ItemService';
import { achievementService } from '../services/AchievementService';
import { audioManager } from '../services/AudioManager';
import { HapticFeedbackUtils } from '../utils/HapticFeedbackUtils';
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
  selectedItem: 'magnifying_glass' | 'iron_fist' | null = null;
  tempRevealedCell: Coordinate | null = null;
  
  // 计时器相关
  startTime: number = 0;
  elapsedTime: number = 0;
  timerInterval: number | null = null;

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
    this.stopTimer();
    
    // 创建空白棋盘
    for (let i: number = 0; i < this.rows; i++) {
      const row: Cell[] = [];
      for (let j: number = 0; j < this.cols; j++) {
        row.push(new Cell(i, j));
      }
      this.board.push(row);
    }
    
    // 随机放置地雷
    this.placeMines();
    // 计算每个格子周围的地雷数
    this.calculateAdjacentMines();
  }

  private placeMines(): void {
    let minesPlaced: number = 0;
    while (minesPlaced < this.mineCount) {
      const x: number = Math.floor(Math.random() * this.rows);
      const y: number = Math.floor(Math.random() * this.cols);
      
      if (!this.board[x][y].isMine) {
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

    if (!this.isValid(x, y) || this.gameOver) {
      return;
    }

    const cell: Cell = this.board[x][y];
    
    if (cell.isRevealed || cell.isFlagged) {
      return;
    }

    cell.isRevealed = true;

    // 如果是地雷，游戏失败
    if (cell.isMine) {
      this.gameOver = true;
      this.gameWon = false;
      this.stopTimer();
      this.revealAllMines();
      // 播放失败音效和触觉反馈
      audioManager.playSound('lose');
      HapticFeedbackUtils.vibrate('failure');
      return;
    }

    // 播放点击音效和触觉反馈
    if (!isAutoReveal) {
      audioManager.playSound('click');
      HapticFeedbackUtils.vibrate('click');
      // 开始计时器（第一次点击时）
      if (this.startTime === 0) {
        this.startTimer();
      }
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
      // 播放胜利音效和触觉反馈
      audioManager.playSound('win');
      HapticFeedbackUtils.vibrate('success');
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
        HapticFeedbackUtils.vibrate('flag');
      }
    }
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
        this.tempRevealedCell = new Coordinate(x, y);
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

  // 清理资源
  destroy(): void {
    this.stopTimer();
    this.selectedItem = null;
    this.tempRevealedCell = null;
  }
}
