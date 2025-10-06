import { BusinessError } from '@ohos.base';
import dataPreferences from '@ohos.data.preferences';
import resourceManager from '@ohos.resourceManager';
import { Level } from '../model/Level';
import common from '@ohos.app.ability.common';

const ADVENTURE_PREFS_FILE = 'adventure_data';
const CURRENT_STAGE_KEY = 'current_stage_index';

interface AdventureStage {
  stageId: string;
  levelId: string;
  introText: string;
}

class AdventureService {
  private stages: AdventureStage[] = [];
  private allLevels: Level[] = [];
  private currentStageIndex: number = 0;
  private preferences: dataPreferences.Preferences | null = null;

  async init(): Promise<void> {
    try {
      const context = common.getAppContext();
      this.preferences = await dataPreferences.getPreferences(context, ADVENTURE_PREFS_FILE);
      this.currentStageIndex = await this.preferences.get(CURRENT_STAGE_KEY, 0) as number;

      const mapRawFile = await resourceManager.getRawFileContent('adventure_map.json');
      const mapJsonString = this.uint8ArrayToString(mapRawFile);
      const adventureMap: { stages: AdventureStage[] } = JSON.parse(mapJsonString);
      this.stages = adventureMap.stages;

      const levelsRawFile = await resourceManager.getRawFileContent('levels.json');
      const levelsJsonString = this.uint8ArrayToString(levelsRawFile);
      this.allLevels = JSON.parse(levelsJsonString);
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize AdventureService: ${error.message}, code: ${error.code}`);
    }
  }

  private uint8ArrayToString(array: Uint8Array): string {
    return String.fromCharCode.apply(null, array);
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
}

export const adventureService = new AdventureService();
