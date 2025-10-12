/**
 * 成就系统服务
 * 
 * 管理玩家成就的解锁、进度跟踪和持久化存储。
 * 
 * 功能包括：
 * - 从JSON文件加载成就配置
 * - 跟踪玩家游戏统计数据（胜利次数、最快时间等）
 * - 自动检测并解锁成就
 * - 持久化保存成就进度和玩家数据
 */
import { Achievement } from '../model/Achievement';
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import util from '@ohos.util';

const PREFS_FILE = 'achievement_data';
const STATS_KEY = 'player_stats';
const ACHIEVEMENTS_KEY = 'unlocked_achievements';

/**
 * 玩家统计数据模型
 * 
 * 记录玩家的游戏表现数据，用于成就解锁条件判断。
 */
export class PlayerStats {
  /** 总胜利次数 */
  wins: number;
  
  /** 最快通关时间（秒） */
  fastestWin: number;
  
  /** 完美胜利次数（不踩雷） */
  flawlessWins: number;

  constructor(wins: number = 0, fastestWin: number = 999, flawlessWins: number = 0) {
    this.wins = wins;
    this.fastestWin = fastestWin;
    this.flawlessWins = flawlessWins;
  }
}

/**
 * 成就服务类
 * 
 * 单例服务，管理所有成就相关逻辑。
 */
class AchievementService {
  /** 所有成就列表 */
  private achievements: Achievement[] = [];
  
  /** 玩家统计数据 */
  private playerStats: PlayerStats = new PlayerStats();
  
  /** 持久化存储实例 */
  private preferences: dataPreferences.Preferences | null = null;

  /**
   * 初始化成就服务
   * 
   * 从资源文件加载成就配置，初始化本地存储，并恢复玩家进度。
   * 必须在使用成就功能前调用。
   * 
   * @param {common.UIAbilityContext | undefined} context - 应用上下文
   * @returns {Promise<void>} 初始化完成的Promise
   */
  async init(context: common.UIAbilityContext | undefined): Promise<void> {
    if (!context) {
      console.error('AchievementService init failed: context is undefined');
      return;
    }
    
    try {
      const rawFile: Uint8Array = await context.resourceManager.getRawFileContent('achievements.json');
      const jsonString: string = this.uint8ArrayToString(rawFile);
      this.achievements = JSON.parse(jsonString) as Achievement[];

      this.preferences = await dataPreferences.getPreferences(context, PREFS_FILE);

      await this.loadProgress();
      this.updateAchievementStatus();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize AchievementService: ${error.message}, code: ${error.code}`);
    }
  }

  /**
   * 将Uint8Array转换为字符串
   * 
   * 使用UTF-8解码器正确解析包含中文的JSON文件。
   * 
   * @param {Uint8Array} array - 原始字节数组
   * @returns {string} 解码后的字符串
   */
  private uint8ArrayToString(array: Uint8Array): string {
    const textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeToString(array);
  }

  /**
   * 从本地存储加载玩家进度
   * 
   * 恢复玩家统计数据和已解锁的成就列表。
   * 如果是首次运行，使用默认值。
   */
  private async loadProgress(): Promise<void> {
    if (!this.preferences) return;
    try {
      const statsJson = (await this.preferences.get(STATS_KEY, '{}')) as string;
      const savedStats: Partial<PlayerStats> = JSON.parse(statsJson);
      // Manually merge properties instead of using spread operator
      if (savedStats.wins !== undefined) {
        this.playerStats.wins = savedStats.wins;
      }
      if (savedStats.fastestWin !== undefined) {
        this.playerStats.fastestWin = savedStats.fastestWin;
      }
      if (savedStats.flawlessWins !== undefined) {
        this.playerStats.flawlessWins = savedStats.flawlessWins;
      }

      const unlockedJson = (await this.preferences.get(ACHIEVEMENTS_KEY, '[]')) as string;
      const unlockedIds: string[] = JSON.parse(unlockedJson);
      this.achievements.forEach((ach: Achievement) => {
        if (unlockedIds.includes(ach.id)) {
          ach.unlocked = true;
        }
      });
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to load achievement progress: ${error.message}, code: ${error.code}`);
    }
  }

  /**
   * 保存玩家进度到本地存储
   * 
   * 持久化玩家统计数据和已解锁的成就ID列表。
   */
  private async saveProgress(): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(STATS_KEY, JSON.stringify(this.playerStats));
      const unlockedIds = this.achievements.filter(a => a.unlocked).map(a => a.id);
      await this.preferences.put(ACHIEVEMENTS_KEY, JSON.stringify(unlockedIds));
      await this.preferences.flush();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to save achievement progress: ${error.message}, code: ${error.code}`);
    }
  }

  /**
   * 更新所有成就的解锁状态
   * 
   * 根据当前玩家统计数据检查所有成就的解锁条件。
   * 在玩家数据变化后调用以自动解锁符合条件的成就。
   */
  private updateAchievementStatus(): void {
    this.checkAchievement('first_win', this.playerStats.wins >= 1);
    this.checkAchievement('ten_wins', this.playerStats.wins >= 10);
    this.checkAchievement('quick_learner', this.playerStats.fastestWin <= 60);
    this.checkAchievement('flawless_victory', this.playerStats.flawlessWins > 0);
  }

  /**
   * 检查并解锁单个成就
   * 
   * 如果条件满足且成就未解锁，则解锁该成就。
   * 
   * @param {string} id - 成就ID
   * @param {boolean} condition - 解锁条件是否满足
   */
  private checkAchievement(id: string, condition: boolean): void {
    const achievement = this.achievements.find(a => a.id === id);
    if (achievement && !achievement.unlocked && condition) {
      achievement.unlocked = true;
    }
  }

  /**
   * 记录一次游戏胜利
   * 
   * 更新玩家统计数据，检查成就解锁条件，并保存进度。
   * 应在玩家获胜时调用。
   * 
   * @param {number} time - 本局游戏用时（秒）
   * @param {boolean} flawless - 是否完美通关（未踩雷）
   * @returns {Promise<void>} 记录完成的Promise
   */
  public async recordGameWin(time: number, flawless: boolean): Promise<void> {
    this.playerStats.wins++;
    if (time < this.playerStats.fastestWin) {
      this.playerStats.fastestWin = time;
    }
    if (flawless) {
      this.playerStats.flawlessWins++;
    }
    this.updateAchievementStatus();
    await this.saveProgress();
  }

  /**
   * 获取所有成就列表
   * 
   * @returns {Achievement[]} 成就数组，包含解锁状态
   */
  public getAchievements(): Achievement[] {
    return this.achievements;
  }

  /**
   * 清理服务资源
   * 
   * 释放引用并重置状态。
   * 应在应用退出时调用。
   */
  destroy(): void {
    this.preferences = null;
    this.achievements = [];
    this.playerStats = new PlayerStats();
  }
}

export const achievementService = new AchievementService();
