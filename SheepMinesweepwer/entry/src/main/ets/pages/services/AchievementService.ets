import { Achievement } from '../model/Achievement';
import dataPreferences from '@ohos.data.preferences';
import { BusinessError } from '@ohos.base';
import { getContext } from '@ohos.abilityAccessCtrl';

const PREFS_FILE = 'achievement_data';
const STATS_KEY = 'player_stats';
const ACHIEVEMENTS_KEY = 'unlocked_achievements';

export interface PlayerStats {
  wins: number;
  fastestWin: number; // in seconds
  flawlessWins: number;
}

class AchievementService {
  private achievements: Achievement[] = [];
  private playerStats: PlayerStats = { wins: 0, fastestWin: 999, flawlessWins: 0 };
  private preferences: dataPreferences.Preferences | null = null;

  async init(): Promise<void> {
    try {
      const context = getContext(this);
      const rawFile = await context.resourceManager.getRawFileContent('achievements.json');
      const jsonString = this.uint8ArrayToString(rawFile);
      this.achievements = JSON.parse(jsonString) as Achievement[];

      this.preferences = await dataPreferences.getPreferences(context, PREFS_FILE);

      await this.loadProgress();
      this.updateAchievementStatus();
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to initialize AchievementService: ${error.message}, code: ${error.code}`);
    }
  }

  private uint8ArrayToString(array: Uint8Array): string {
    let result = "";
    for (let i = 0; i < array.length; i++) {
      result += String.fromCharCode(array[i]);
    }
    return result;
  }

  private async loadProgress(): Promise<void> {
    if (!this.preferences) return;
    try {
      const statsJson = await this.preferences.get(STATS_KEY, '{}') as string;
      const savedStats: Partial<PlayerStats> = JSON.parse(statsJson);
      this.playerStats = { ...this.playerStats, ...savedStats };

      const unlockedJson = await this.preferences.get(ACHIEVEMENTS_KEY, '[]') as string;
      const unlockedIds: string[] = JSON.parse(unlockedJson);
      this.achievements.forEach(ach => {
        if (unlockedIds.includes(ach.id)) {
          ach.unlocked = true;
        }
      });
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to load achievement progress: ${error.message}, code: ${error.code}`);
    }
  }

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

  private updateAchievementStatus(): void {
    this.checkAchievement('first_win', this.playerStats.wins >= 1);
    this.checkAchievement('ten_wins', this.playerStats.wins >= 10);
    this.checkAchievement('quick_learner', this.playerStats.fastestWin <= 60);
    this.checkAchievement('flawless_victory', this.playerStats.flawlessWins > 0);
  }

  private checkAchievement(id: string, condition: boolean): void {
    const achievement = this.achievements.find(a => a.id === id);
    if (achievement && !achievement.unlocked && condition) {
      achievement.unlocked = true;
    }
  }

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

  public getAchievements(): Achievement[] {
    return this.achievements;
  }
}

export const achievementService = new AchievementService();
