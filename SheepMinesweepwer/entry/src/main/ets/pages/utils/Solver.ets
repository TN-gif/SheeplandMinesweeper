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
 * 扫雷求解器
 * 使用确定性逻辑规则验证棋盘是否可解
 * 不进行猜测，仅应用基本逻辑推理
 * 
 * 用途：
 * 1. 验证生成的棋盘是否可在不猜测的情况下解开
 * 2. 确保关卡质量（所有关卡都应该可解）
 */
export class Solver {
  /**
   * 尝试求解棋盘
   * @param board 游戏棋盘（已生成地雷和计算adjacentMines）
   * @param rows 行数
   * @param cols 列数
   * @param mineCount 地雷数量
   * @param startX 起始点X坐标（模拟玩家第一次点击）
   * @param startY 起始点Y坐标
   * @returns 是否可解（true=可解，false=不可解或需要猜测）
   */
  static solve(board: Cell[][], rows: number, cols: number, mineCount: number, startX: number = 0, startY: number = 0): boolean {
    // 深拷贝棋盘（手动拷贝以保持Cell类型）
    const boardCopy: Cell[][] = Solver.deepCopyBoard(board, rows, cols);
    
    // 模拟第一次点击（展开起始位置）
    Solver.revealCellWithFloodFill(boardCopy, startX, startY, rows, cols);
    
    let movesMade: boolean = true;
    let iterationCount: number = 0;
    const maxIterations: number = rows * cols * 2; // 防止无限循环

    while (movesMade && iterationCount < maxIterations) {
      movesMade = false;
      iterationCount++;

      for (let r: number = 0; r < rows; r++) {
        for (let c: number = 0; c < cols; c++) {
          const cell: Cell = boardCopy[r][c];
          // 只处理已翻开且有数字的格子
          if (!cell.isRevealed || cell.adjacentMines === 0) {
            continue;
          }

          const stats: NeighborStats = Solver.getNeighborStats(boardCopy, r, c, rows, cols);

          // Rule 1 (和弦规则): 如果已插旗数等于数字，翻开其余格子
          if (stats.flagged === cell.adjacentMines && stats.unrevealed > stats.flagged) {
            if (Solver.revealNeighbors(boardCopy, r, c, rows, cols)) {
              movesMade = true;
            }
          }

          // Rule 2 (插旗规则): 如果剩余未翻开格子数等于数字减去已插旗数，全部插旗
          const remainingMines: number = cell.adjacentMines - stats.flagged;
          const unrevealedNotFlagged: number = stats.unrevealed - stats.flagged;
          if (remainingMines > 0 && unrevealedNotFlagged === remainingMines) {
            if (Solver.flagNeighbors(boardCopy, r, c, rows, cols)) {
              movesMade = true;
            }
          }
        }
      }
    }

    // 检查是否求解成功（所有非地雷格子都被翻开）
    let revealedCount: number = 0;
    for (let r: number = 0; r < rows; r++) {
      for (let c: number = 0; c < cols; c++) {
        if (boardCopy[r][c].isRevealed) {
          revealedCount++;
        }
      }
    }

    const expectedRevealed: number = rows * cols - mineCount;
    const isSolved: boolean = revealedCount === expectedRevealed;
    
    // 调试日志
    if (!isSolved) {
      console.log(`[Solver] 棋盘不可解: 已翻开${revealedCount}/${expectedRevealed}, 迭代${iterationCount}次`);
    }
    
    return isSolved;
  }

  /**
   * 深拷贝棋盘（保持Cell类型）
   */
  private static deepCopyBoard(board: Cell[][], rows: number, cols: number): Cell[][] {
    const copy: Cell[][] = [];
    for (let r: number = 0; r < rows; r++) {
      const row: Cell[] = [];
      for (let c: number = 0; c < cols; c++) {
        const original: Cell = board[r][c];
        const newCell: Cell = new Cell(original.x, original.y);
        newCell.isMine = original.isMine;
        newCell.adjacentMines = original.adjacentMines;
        newCell.isRevealed = original.isRevealed;
        newCell.isFlagged = original.isFlagged;
        row.push(newCell);
      }
      copy.push(row);
    }
    return copy;
  }

  /**
   * 翻开格子并进行洪水填充（模拟玩家点击）
   */
  private static revealCellWithFloodFill(board: Cell[][], r: number, c: number, rows: number, cols: number): void {
    if (!Solver.isValid(r, c, rows, cols)) {
      return;
    }
    
    const cell: Cell = board[r][c];
    if (cell.isRevealed || cell.isFlagged || cell.isMine) {
      return;
    }
    
    cell.isRevealed = true;
    
    // 如果周围没有地雷，递归翻开周围格子
    if (cell.adjacentMines === 0) {
      for (let i: number = -1; i <= 1; i++) {
        for (let j: number = -1; j <= 1; j++) {
          if (i === 0 && j === 0) continue;
          Solver.revealCellWithFloodFill(board, r + i, c + j, rows, cols);
        }
      }
    }
  }

  private static getNeighborStats(board: Cell[][], r: number, c: number, rows: number, cols: number): NeighborStats {
    let unrevealed: number = 0;
    let flagged: number = 0;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR: number = r + i;
        const newC: number = c + j;
        if (Solver.isValid(newR, newC, rows, cols)) {
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

  /**
   * 翻开周围所有未插旗的格子
   */
  private static revealNeighbors(board: Cell[][], r: number, c: number, rows: number, cols: number): boolean {
    let changed: boolean = false;
    for (let i: number = -1; i <= 1; i++) {
      for (let j: number = -1; j <= 1; j++) {
        if (i === 0 && j === 0) continue;
        const newR: number = r + i;
        const newC: number = c + j;
        if (Solver.isValid(newR, newC, rows, cols)) {
          const neighbor: Cell = board[newR][newC];
          if (!neighbor.isRevealed && !neighbor.isFlagged && !neighbor.isMine) {
            // 使用洪水填充翻开格子（如果是0则会自动展开）
            Solver.revealCellWithFloodFill(board, newR, newC, rows, cols);
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
        if (Solver.isValid(newR, newC, rows, cols)) {
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
