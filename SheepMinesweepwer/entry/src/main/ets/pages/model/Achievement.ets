/**
 * 成就数据模型
 * 
 * 表示游戏中的一个成就项，包含成就的描述和解锁状态。
 * 用于激励玩家完成特定目标（如首次胜利、快速通关等）。
 */
export class Achievement {
  /** 成就唯一标识符 */
  id: string;
  
  /** 成就显示名称 */
  name: string;
  
  /** 成就描述文本，说明解锁条件 */
  description: string;
  
  /** 是否已解锁 */
  unlocked: boolean;

  /**
   * 创建一个成就实例
   * 
   * @param {string} id - 成就唯一标识
   * @param {string} name - 成就名称
   * @param {string} description - 成就描述
   * @param {boolean} [unlocked=false] - 初始解锁状态，默认未解锁
   */
  constructor(id: string, name: string, description: string, unlocked: boolean = false) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.unlocked = unlocked;
  }
}
