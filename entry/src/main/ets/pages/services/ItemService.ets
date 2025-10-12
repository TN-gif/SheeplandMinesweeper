/**
 * 道具系统服务
 * 
 * 管理玩家的道具背包和使用逻辑。
 * 
 * 功能包括：
 * - 初始化默认道具（每局游戏开始时）
 * - 道具使用和数量扣减
 * - 道具数量持久化存储
 * - 重置道具数量
 * 
 * 设计要点：
 * - 每局游戏开始时重置道具数量为默认值
 * - 道具消耗会立即保存到本地
 */
import { Item } from '../model/Item';
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';

const ITEM_PREFS_FILE = 'item_data';
const INVENTORY_KEY = 'player_inventory';

/**
 * 道具服务类
 * 
 * 单例服务，管理所有道具相关逻辑。
 */
class ItemService {
  /** 玩家道具背包，包含所有可用道具 */
  private inventory: Item[] = [
    new Item('magnifying_glass', '慢羊羊的放大镜', '探测一个格子是否安全', 3)
  ];
  
  /** 持久化存储实例 */
  private preferences: dataPreferences.Preferences | null = null;

  /**
   * 初始化道具服务
   * 
   * 初始化本地存储并加载保存的道具数量。
   * 必须在使用道具功能前调用。
   * 
   * @param {common.UIAbilityContext | undefined} context - 应用上下文
   * @returns {Promise<void>} 初始化完成的Promise
   */
  async init(context: common.UIAbilityContext | undefined): Promise<void> {
    if (!context) {
      console.error('ItemService init failed: context is undefined');
      return;
    }
    
    try {
      this.preferences = await dataPreferences.getPreferences(context, ITEM_PREFS_FILE);
      await this.loadInventory();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize ItemService: ${error.message}, code: ${error.code}`);
    }
  }

  /**
   * 从本地存储加载道具背包
   * 
   * 恢复上次保存的道具数量。
   * 如果是首次运行，使用默认值。
   */
  private async loadInventory(): Promise<void> {
    if (!this.preferences) return;
    try {
      const savedInventoryJson = await this.preferences.get(INVENTORY_KEY, '[]') as string;
      const savedInventory: Item[] = JSON.parse(savedInventoryJson);

      if (savedInventory.length > 0) {
        this.inventory.forEach(item => {
          const savedItem = savedInventory.find(si => si.id === item.id);
          if (savedItem) {
            item.quantity = savedItem.quantity;
          }
        });
      }
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to load inventory: ${error.message}, code: ${error.code}`);
    }
  }

  /**
   * 保存道具背包到本地存储
   * 
   * 持久化当前所有道具的数量。
   */
  private async saveInventory(): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(INVENTORY_KEY, JSON.stringify(this.inventory));
      await this.preferences.flush();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to save inventory: ${error.message}, code: ${error.code}`);
    }
  }

  /**
   * 获取玩家道具背包
   * 
   * @returns {Item[]} 道具数组
   */
  public getInventory(): Item[] {
    return this.inventory;
  }

  /**
   * 使用一个道具
   * 
   * 扣减道具数量并保存。
   * 如果道具数量不足，返回false。
   * 
   * @param {string} itemId - 道具ID
   * @returns {boolean} 是否使用成功
   */
  public useItem(itemId: 'magnifying_glass'): boolean {
    const item = this.inventory.find(i => i.id === itemId);
    if (item && item.quantity > 0) {
      item.quantity--;
      this.saveInventory();
      return true;
    }
    return false;
  }

  /**
   * 重置道具数量为默认值
   * 
   * 应在每局游戏开始时调用，确保玩家有固定数量的道具。
   * 
   * @returns {Promise<void>} 重置完成的Promise
   */
  public async resetInventory(): Promise<void> {
    this.inventory = [
      new Item('magnifying_glass', '慢羊羊的放大镜', '探测一个格子是否安全', 3)
    ];
    await this.saveInventory();
  }

  /**
   * 清理服务资源
   * 
   * 释放引用并重置状态。
   * 应在应用退出时调用。
   */
  destroy(): void {
    this.preferences = null;
    this.inventory = [];
  }
}

export const itemService = new ItemService();
