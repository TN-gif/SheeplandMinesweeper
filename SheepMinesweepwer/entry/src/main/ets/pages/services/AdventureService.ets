import dataPreferences from '@ohos.data.preferences';
import resourceManager from '@ohos.resourceManager';
import { Level } from '../model/Level';

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

  async init() {
    // Load adventure map
    const mapRawFile = await resourceManager.getRawFileContent('adventure_map.json');
    const mapJsonString = String.fromCharCode(...new Uint8Array(mapRawFile.buffer));
    const adventureMap = JSON.parse(mapJsonString);
    this.stages = adventureMap.stages;

    // Load all levels so we can find them by id
    const levelsRawFile = await resourceManager.getRawFileContent('levels.json');
    const levelsJsonString = String.fromCharCode(...new Uint8Array(levelsRawFile.buffer));
    this.allLevels = JSON.parse(levelsJsonString);

    // Load progress
    const context = getContext(this);
    this.preferences = await dataPreferences.getPreferences(context, ADVENTURE_PREFS_FILE);
    this.currentStageIndex = await this.preferences.get(CURRENT_STAGE_KEY, 0) as number;
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

  public async completeStage() {
    if (this.currentStageIndex < this.stages.length - 1) {
      this.currentStageIndex++;
      await this.preferences!.put(CURRENT_STAGE_KEY, this.currentStageIndex);
      await this.preferences!.flush();
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
