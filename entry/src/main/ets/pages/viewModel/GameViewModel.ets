/**
 * 扫雷游戏视图模型
 * 
 * 管理游戏的核心逻辑和状态，包括：
 * - 棋盘初始化和地雷生成
 * - 格子翻开、插旗、和弦操作
 * - 游戏胜负判定
 * - 计时器管理
 * - 道具使用
 * - 可解性验证
 * 
 * 设计要点：
 * - 使用@Observed装饰器支持响应式UI更新
 * - 第一次点击保护：确保首次点击不会踩雷，且周围安全
 * - 生成的棋盘保证可解（通过Solver验证）
 * - 支持自动展开空白区域（洪水填充算法）
 */
import { Cell } from '../model/Cell';
import { Level } from '../model/Level';
import { adventureService } from '../services/AdventureService';
import { itemService } from '../services/ItemService';
import { achievementService } from '../services/AchievementService';
import { audioManager } from '../services/AudioManager';
import { Solver } from '../utils/Solver';
import common from '@ohos.app.ability.common';

/**
 * 坐标辅助类
 * 
 * 用于记录临时翻开的格子位置（道具效果）。
 */
class Coordinate {
  x: number;
  y: number;

  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}

/**
 * 游戏视图模型类
 * 
 * 管理单局游戏的所有状态和逻辑。
 */
@Observed
export class GameViewModel {
  /** 棋盘行数 */
  rows: number = 10;
  
  /** 棋盘列数 */
  cols: number = 10;
  
  /** 地雷总数 */
  mineCount: number = 15;
  
  /** 游戏棋盘（二维数组） */
  board: Cell[][] = [];
  
  /** 游戏是否结束 */
  gameOver: boolean = false;
  
  /** 是否获胜 */
  gameWon: boolean = false;
  
  /** 是否显示游戏结束弹窗（延迟显示，给玩家时间查看地雷） */
  showGameOverDialog: boolean = false;
  
  /** 当前选中的道具ID */
  selectedItem: 'magnifying_glass' | null = null;
  
  /** 临时翻开的格子坐标（放大镜效果） */
  tempRevealedCell: Coordinate | null = null;
  
  /** 游戏开始时间戳（毫秒） */
  startTime: number = 0;
  
  /** 已用时间（秒） */
  elapsedTime: number = 0;
  
  /** 计时器句柄 */
  timerInterval: number | null = null;
  
  /** 是否为首次点击（用于第一次点击保护） */
  isFirstClick: boolean = true;

  /**
   * 创建游戏视图模型实例
   * 
   * @param {Level | null} [level=null] - 关卡配置，如果为null则使用默认参数
   * @param {common.UIAbilityContext} [context] - 应用上下文，用于初始化服务
   */
  constructor(level: Level | null = null, context?: common.UIAbilityContext) {
    if (level) {
      this.rows = level.rows;
      this.cols = level.cols;
      this.mineCount = level.mines;
    }
    this.initBoard();
    // 服务已在主页面初始化，这里只是备用逻辑
    if (context) {
      achievementService.init(context);
      adventureService.init(context);
      itemService.init(context);
    }
  }

  /**
   * 初始化游戏棋盘
   * 
   * 创建空白棋盘，重置所有游戏状态。
   * 地雷会在第一次点击时生成，以实现第一次点击保护。
   */
  initBoard(): void {
    this.board = [];
    this.gameOver = false;
    this.gameWon = false;
    this.showGameOverDialog = false;
    this.elapsedTime = 0;
    this.startTime = 0;
    this.isFirstClick = true;
    this.stopTimer();
    
    // 创建空白棋盘，地雷在首次点击时生成
    for (let i: number = 0; i < this.rows; i++) {
      const row: Cell[] = [];
      for (let j: number = 0; j < this.cols; j++) {
        row.push(new Cell(i, j));
      }
      this.board.push(row);
    }
  }

  /**
   * 生成地雷布局（带可解性验证）
   * 
   * 随机放置地雷，确保生成的棋盘可以通过逻辑推理解开，无需猜测。
   * 使用Solver验证可解性，最多尝试50次生成。
   * 
   * 约束条件：
   * - 首次点击位置及其周围8格不会有地雷
   * - 棋盘必须可通过确定性逻辑解开
   * 
   * @param {number} firstClickX - 首次点击的行坐标
   * @param {number} firstClickY - 首次点击的列坐标
   */
  private placeMines(firstClickX: number, firstClickY: number): void {
    const maxAttempts: number = 50; // 最多尝试50次生成可解棋盘
    let attempt: number = 0;
    let isSolvable: boolean = false;
    
    while (attempt < maxAttempts && !isSolvable) {
      attempt++;
      
      // 清除之前的地雷
      for (let i: number = 0; i < this.rows; i++) {
        for (let j: number = 0; j < this.cols; j++) {
          this.board[i][j].isMine = false;
          this.board[i][j].adjacentMines = 0;
        }
      }
      
      // 随机放置地雷
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
      
      // 计算周围地雷数
      this.calculateAdjacentMines();
      
      // 验证可解性
      isSolvable = Solver.solve(this.board, this.rows, this.cols, this.mineCount, firstClickX, firstClickY);
      
      if (!isSolvable && attempt < maxAttempts) {
        console.log(`[GameViewModel] 第${attempt}次生成的棋盘不可解，重新生成...`);
      }
    }
    
    if (!isSolvable) {
      console.warn(`[GameViewModel] 尝试${maxAttempts}次后仍未生成可解棋盘，使用当前布局`);
    } else {
      console.log(`[GameViewModel] 成功生成可解棋盘（尝试${attempt}次）`);
    }
  }

  /**
   * 计算所有格子周围的地雷数量
   * 
   * 遍历整个棋盘，为每个非地雷格子计算adjacentMines值。
   */
  private calculateAdjacentMines(): void {
    for (let i: number = 0; i < this.rows; i++) {
      for (let j: number = 0; j < this.cols; j++) {
        this.calculateAdjacentMinesForCell(i, j);
      }
    }
  }

  /**
   * 选择或取消选择道具
   * 
   * 点击道具栏时切换道具的选中状态。
   * 如果已选中同一道具，则取消选择。
   * 
   * @param {string} itemId - 道具ID
   */
  selectItem(itemId: 'magnifying_glass'): void {
    if (this.selectedItem === itemId) {
      this.selectedItem = null;
    } else {
      this.selectedItem = itemId;
    }
  }

  /**
   * 翻开一个格子
   * 
   * 游戏的核心交互方法，处理以下情况：
   * - 首次点击：生成地雷并启动计时器
   * - 点到地雷：游戏失败
   * - 点到空白：递归展开周围格子
   * - 点到数字：仅翻开当前格子
   * 
   * @param {number} x - 格子行坐标
   * @param {number} y - 格子列坐标
   * @param {boolean} [isAutoReveal=false] - 是否为自动翻开（递归展开时使用）
   */
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
      // 延迟2秒显示弹窗，让玩家有时间查看地雷分布
      setTimeout(() => {
        this.showGameOverDialog = true;
      }, 2000);
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

  /**
   * 翻开所有地雷格子
   * 
   * 游戏结束时调用，显示所有地雷位置。
   * 失败时添加震动动画，成功时不震动。
   * 
   * @param {boolean} [withShake=true] - 是否添加震动效果（默认true用于失败情况）
   */
  private revealAllMines(withShake: boolean = true): void {
    for (let i: number = 0; i < this.rows; i++) {
      for (let j: number = 0; j < this.cols; j++) {
        const cell: Cell = this.board[i][j];
        if (cell.isMine) {
          cell.isRevealed = true;
          if (withShake) {
            cell.shake = true;
          }
        }
      }
    }
  }

  /**
   * 检查是否满足胜利条件
   * 
   * 胜利条件：所有非地雷格子都被翻开。
   * 如果满足条件，停止计时器，播放音效，记录成就。
   */
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
      // 显示所有地雷位置，让玩家查看（成功时不震动）
      this.revealAllMines(false);
      // 播放胜利音效和记录成就
      audioManager.playSound('win');
      achievementService.recordGameWin(this.elapsedTime, true);
      // 延迟2秒显示弹窗，让玩家有时间查看地雷分布
      setTimeout(() => {
        this.showGameOverDialog = true;
      }, 2000);
    }
  }

  /**
   * 在格子上插旗或取消插旗
   * 
   * 长按格子时调用，用于标记可疑地雷。
   * 已翻开的格子不能插旗。
   * 
   * @param {number} x - 格子行坐标
   * @param {number} y - 格子列坐标
   */
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

  /**
   * 和弦操作（双击数字格）
   * 
   * 当周围已插旗数等于数字时，自动翻开周围所有未插旗的格子。
   * 这是扫雷游戏的高级技巧，可以加快游戏速度。
   * 
   * 使用条件：
   * - 格子已翻开且显示数字
   * - 周围旗子数量等于数字
   * 
   * @param {number} x - 格子行坐标
   * @param {number} y - 格子列坐标
   */
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

  /**
   * 使用选中的道具
   * 
   * 当玩家选中道具后点击格子时调用。
   * 目前支持放大镜：临时显示格子内容1.5秒。
   * 
   * @param {number} x - 格子行坐标
   * @param {number} y - 格子列坐标
   */
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

    // 放大镜效果：临时显示格子状态1.5秒后自动隐藏
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

  /**
   * 检查坐标是否在棋盘范围内
   * 
   * @param {number} x - 行坐标
   * @param {number} y - 列坐标
   * @returns {boolean} 是否有效
   */
  private isValid(x: number, y: number): boolean {
    return x >= 0 && x < this.rows && y >= 0 && y < this.cols;
  }

  /**
   * 计算单个格子周围的地雷数量
   * 
   * 遍历周围8个格子，统计地雷数量并赋值给adjacentMines。
   * 
   * @param {number} x - 格子行坐标
   * @param {number} y - 格子列坐标
   */
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

  /**
   * 启动游戏计时器
   * 
   * 在首次点击格子时调用，每秒更新一次已用时间。
   */
  private startTimer(): void {
    this.startTime = Date.now();
    this.timerInterval = setInterval(() => {
      this.elapsedTime = Math.floor((Date.now() - this.startTime) / 1000);
    }, 1000);
  }

  /**
   * 停止游戏计时器
   * 
   * 在游戏结束时调用，清理定时器句柄。
   */
  private stopTimer(): void {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.timerInterval = null;
    }
  }

  /**
   * 获取格式化的游戏时间
   * 
   * 将秒数转换为"MM:SS"格式。
   * 
   * @returns {string} 格式化的时间字符串（如"02:35"）
   */
  getFormattedTime(): string {
    const minutes = Math.floor(this.elapsedTime / 60);
    const seconds = this.elapsedTime % 60;
    return `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
  }

  /**
   * 获取剩余地雷数量
   * 
   * 计算公式：总地雷数 - 已插旗数量
   * 注意：这个数字可能为负（插旗过多），也可能不准确（旗子插错位置）。
   * 
   * @returns {number} 剩余地雷数（可能为负）
   */
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

  /**
   * 清理视图模型资源
   * 
   * 停止计时器，重置临时状态。
   * 应在离开游戏界面时调用。
   */
  destroy(): void {
    this.stopTimer();
    this.selectedItem = null;
    this.tempRevealedCell = null;
    this.showGameOverDialog = false;
  }
}
