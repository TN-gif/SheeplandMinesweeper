/**
 * 关卡配置数据模型
 * 
 * 定义扫雷游戏的关卡参数，包括棋盘大小、地雷数量、解锁状态等。
 * 用于挑战模式和冒险模式的关卡管理。
 */
export class Level {
  /** 关卡唯一标识符 */
  levelId: string;
  
  /** 关卡显示名称 */
  name: string;
  
  /** 棋盘行数 */
  rows: number;
  
  /** 棋盘列数 */
  cols: number;
  
  /** 地雷数量 */
  mines: number;
  
  /** 时间限制（秒），可选，用于挑战关卡 */
  timeLimit?: number;
  
  /** 是否已解锁，控制玩家是否可以进入该关卡 */
  isUnlocked: boolean;

  /**
   * 创建一个关卡实例
   * 
   * @param {string} levelId - 关卡唯一标识
   * @param {string} name - 关卡名称
   * @param {number} rows - 棋盘行数
   * @param {number} cols - 棋盘列数
   * @param {number} mines - 地雷数量
   * @param {boolean} isUnlocked - 是否已解锁
   * @param {number} [timeLimit] - 可选的时间限制（秒）
   */
  constructor(
    levelId: string,
    name: string,
    rows: number,
    cols: number,
    mines: number,
    isUnlocked: boolean,
    timeLimit?: number
  ) {
    this.levelId = levelId;
    this.name = name;
    this.rows = rows;
    this.cols = cols;
    this.mines = mines;
    this.isUnlocked = isUnlocked;
    this.timeLimit = timeLimit;
  }
}
