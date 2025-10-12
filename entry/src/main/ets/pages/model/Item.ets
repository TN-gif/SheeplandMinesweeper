/**
 * 游戏道具数据模型
 * 
 * 表示玩家背包中的一个道具，包含道具信息和数量。
 * 目前支持的道具类型：
 * - magnifying_glass（放大镜）：可探测格子是否安全
 */
export class Item {
  /** 道具唯一标识，目前仅支持 'magnifying_glass' */
  id: 'magnifying_glass';
  
  /** 道具显示名称 */
  name: string;
  
  /** 道具功能描述 */
  description: string;
  
  /** 道具当前拥有数量 */
  quantity: number;

  /**
   * 创建一个道具实例
   * 
   * @param {string} id - 道具唯一标识
   * @param {string} name - 道具名称
   * @param {string} description - 道具描述
   * @param {number} quantity - 初始数量
   */
  constructor(id: 'magnifying_glass', name: string, description: string, quantity: number) {
    this.id = id;
    this.name = name;
    this.description = description;
    this.quantity = quantity;
  }
}
