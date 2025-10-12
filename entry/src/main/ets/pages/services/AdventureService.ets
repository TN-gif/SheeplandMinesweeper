/**
 * 冒险模式服务
 * 
 * 管理冒险模式的关卡进度和故事流程。
 * 
 * 功能包括：
 * - 加载冒险地图配置和关卡数据
 * - 跟踪玩家当前进度（第几关）
 * - 管理关卡顺序解锁机制
 * - 持久化保存进度
 */
import { BusinessError } from '@ohos.base';
import dataPreferences from '@ohos.data.preferences';
import resourceManager from '@ohos.resourceManager';
import { Level } from '../model/Level';
import common from '@ohos.app.ability.common';
import util from '@ohos.util';

const ADVENTURE_PREFS_FILE = 'adventure_data';
const CURRENT_STAGE_KEY = 'current_stage_index';

/** 关卡JSON数据接口 */
interface StageJsonData {
  stageId: string;
  levelId: string;
  introText: string;
}

/** 关卡配置JSON数据接口 */
interface LevelJsonData {
  levelId: string;
  name: string;
  rows: number;
  cols: number;
  mines: number;
  isUnlocked: boolean;
  timeLimit?: number;
}

/**
 * 冒险关卡数据模型
 * 
 * 表示冒险模式中的一个故事关卡，包含引导文本和对应的游戏关卡。
 */
export class AdventureStage {
  /** 关卡唯一标识 */
  stageId: string;
  
  /** 对应的游戏关卡ID */
  levelId: string;
  
  /** 关卡引导文本（剧情提示） */
  introText: string;

  constructor(stageId: string, levelId: string, introText: string) {
    this.stageId = stageId;
    this.levelId = levelId;
    this.introText = introText;
  }
}

/**
 * 冒险地图数据模型（暂未使用）
 */
class AdventureMap {
  stages: AdventureStage[];

  constructor(stages: AdventureStage[]) {
    this.stages = stages;
  }
}

/**
 * 冒险服务类
 * 
 * 单例服务，管理冒险模式的所有逻辑。
 */
class AdventureService {
  /** 所有冒险关卡列表 */
  private stages: AdventureStage[] = [];
  
  /** 所有可用的游戏关卡配置 */
  private allLevels: Level[] = [];
  
  /** 玩家当前进度（关卡索引） */
  private currentStageIndex: number = 0;
  
  /** 持久化存储实例 */
  private preferences: dataPreferences.Preferences | null = null;

  /**
   * 初始化冒险服务
   * 
   * 从JSON文件加载冒险地图和关卡配置，恢复玩家进度。
   * 必须在使用冒险模式前调用。
   * 
   * @param {common.UIAbilityContext | undefined} context - 应用上下文
   * @returns {Promise<void>} 初始化完成的Promise
   */
  async init(context: common.UIAbilityContext | undefined): Promise<void> {
    if (!context) {
      console.error('AdventureService init failed: context is undefined');
      return;
    }
    
    try {
      this.preferences = await dataPreferences.getPreferences(context, ADVENTURE_PREFS_FILE);
      this.currentStageIndex = (await this.preferences.get(CURRENT_STAGE_KEY, 0)) as number;

      const mapRawFile: Uint8Array = await context.resourceManager.getRawFileContent('adventure_map.json');
      const mapJsonString: string = this.uint8ArrayToString(mapRawFile);
      const mapData = JSON.parse(mapJsonString) as Record<string, StageJsonData[]>;
      // 将JSON对象转换为AdventureStage实例
      this.stages = mapData['stages'].map((data: StageJsonData) => {
        return new AdventureStage(
          data.stageId,
          data.levelId,
          data.introText
        );
      });

      // 从 adventure_levels.json 加载冒险模式的关卡
      const levelsRawFile: Uint8Array = await context.resourceManager.getRawFileContent('adventure_levels.json');
      const levelsJsonString: string = this.uint8ArrayToString(levelsRawFile);
      const levelsData = JSON.parse(levelsJsonString) as LevelJsonData[];
      // 将JSON对象转换为Level实例
      this.allLevels = levelsData.map((data: LevelJsonData) => {
        return new Level(
          data.levelId,
          data.name,
          data.rows,
          data.cols,
          data.mines,
          data.isUnlocked,
          data.timeLimit
        );
      });
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize AdventureService: ${error.message}, code: ${error.code}`);
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
   * 获取当前应该挑战的关卡
   * 
   * 根据玩家进度返回下一个未完成的关卡。
   * 如果所有关卡已完成，返回null。
   * 
   * @returns {AdventureStage | null} 当前关卡，或null（冒险已完成）
   */
  public getCurrentStage(): AdventureStage | null {
    if (this.currentStageIndex < this.stages.length) {
      return this.stages[this.currentStageIndex];
    }
    return null;
  }

  /**
   * 根据冒险关卡获取对应的游戏关卡配置
   * 
   * @param {AdventureStage} stage - 冒险关卡
   * @returns {Level | null} 对应的游戏关卡配置
   */
  public getLevelForStage(stage: AdventureStage): Level | null {
    return this.allLevels.find(level => level.levelId === stage.levelId) || null;
  }

  /**
   * 标记当前关卡为已完成
   * 
   * 推进玩家进度到下一关并保存。
   * 应在玩家成功通关后调用。
   * 
   * @returns {Promise<void>} 完成操作的Promise
   */
  public async completeStage(): Promise<void> {
    if (this.currentStageIndex < this.stages.length - 1 && this.preferences) {
      this.currentStageIndex++;
      try {
        await this.preferences.put(CURRENT_STAGE_KEY, this.currentStageIndex);
        await this.preferences.flush();
      } catch (e) {
        const error = e as BusinessError;
        console.error(`Failed to save adventure progress: ${error.message}, code: ${error.code}`);
      }
    }
  }

  /**
   * 获取所有冒险关卡列表
   * 
   * @returns {AdventureStage[]} 关卡数组
   */
  public getStages(): AdventureStage[] {
    return this.stages;
  }

  /**
   * 获取玩家当前进度索引
   * 
   * @returns {number} 当前关卡索引（从0开始）
   */
  public getCurrentStageIndex(): number {
    return this.currentStageIndex;
  }

  /**
   * 清理服务资源
   * 
   * 释放引用并重置状态。
   * 应在应用退出时调用。
   */
  destroy(): void {
    this.preferences = null;
    this.stages = [];
    this.allLevels = [];
  }
}

export const adventureService = new AdventureService();
