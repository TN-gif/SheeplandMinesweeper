import { BusinessError } from '@ohos.base';
import dataPreferences from '@ohos.data.preferences';
import resourceManager from '@ohos.resourceManager';
import { Level } from '../model/Level';
import common from '@ohos.app.ability.common';
import util from '@ohos.util';

const ADVENTURE_PREFS_FILE = 'adventure_data';
const CURRENT_STAGE_KEY = 'current_stage_index';

export class AdventureStage {
  stageId: string;
  levelId: string;
  introText: string;

  constructor(stageId: string, levelId: string, introText: string) {
    this.stageId = stageId;
    this.levelId = levelId;
    this.introText = introText;
  }
}

class AdventureMap {
  stages: AdventureStage[];

  constructor(stages: AdventureStage[]) {
    this.stages = stages;
  }
}

class AdventureService {
  private stages: AdventureStage[] = [];
  private allLevels: Level[] = [];
  private currentStageIndex: number = 0;
  private preferences: dataPreferences.Preferences | null = null;

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
      const adventureMap: AdventureMap = JSON.parse(mapJsonString);
      this.stages = adventureMap.stages;

      const levelsRawFile: Uint8Array = await context.resourceManager.getRawFileContent('levels.json');
      const levelsJsonString: string = this.uint8ArrayToString(levelsRawFile);
      this.allLevels = JSON.parse(levelsJsonString);
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize AdventureService: ${error.message}, code: ${error.code}`);
    }
  }

  private uint8ArrayToString(array: Uint8Array): string {
    // 使用UTF-8解码器正确解析中文（使用新的API）
    const textDecoder = util.TextDecoder.create('utf-8');
    return textDecoder.decodeToString(array);
  }

  public getCurrentStage(): AdventureStage | null {
    if (this.currentStageIndex < this.stages.length) {
      return this.stages[this.currentStageIndex];
    }
    return null; // Adventure completed
  }

  public getLevelForStage(stage: AdventureStage): Level | null {
    return this.allLevels.find(level => level.levelId === stage.levelId) || null;
  }

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

  public getStages(): AdventureStage[] {
    return this.stages;
  }

  public getCurrentStageIndex(): number {
    return this.currentStageIndex;
  }

  // 清理资源
  destroy(): void {
    this.preferences = null;
    this.stages = [];
    this.allLevels = [];
  }
}

export const adventureService = new AdventureService();
