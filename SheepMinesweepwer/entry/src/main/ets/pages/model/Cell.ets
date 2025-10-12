/**
 * 扫雷游戏的单个格子数据模型
 * 
 * 封装了一个游戏格子的所有状态信息，包括：
 * - 是否为地雷
 * - 是否已翻开
 * - 是否已插旗
 * - 周围地雷数量
 * - 动画状态
 */
export class Cell {
  /** 是否为地雷格子 */
  isMine: boolean = false;
  
  /** 是否已被翻开（玩家可见） */
  isRevealed: boolean = false;
  
  /** 是否已插旗标记 */
  isFlagged: boolean = false;
  
  /** 周围8个格子中的地雷数量（0-8） */
  adjacentMines: number = 0;
  
  /** 格子在棋盘中的行坐标 */
  x: number;
  
  /** 格子在棋盘中的列坐标 */
  y: number;
  
  /** 震动动画标记，用于游戏失败时的视觉反馈 */
  shake: boolean = false;

  /**
   * 创建一个游戏格子实例
   * 
   * @param {number} x - 格子的行坐标
   * @param {number} y - 格子的列坐标
   */
  constructor(x: number, y: number) {
    this.x = x;
    this.y = y;
  }
}
