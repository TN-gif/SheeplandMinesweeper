import { Achievement } from '../model/Achievement';
import dataPreferences from '@ohos.data.preferences';
import resourceManager from '@ohos.resourceManager';

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

  async init() {
    // Load default achievements from raw file
    const rawFile = await resourceManager.getRawFileContent('achievements.json');
    const jsonString = String.fromCharCode(...new Uint8Array(rawFile.buffer));
    this.achievements = JSON.parse(jsonString);

    // Get preferences instance
    const context = getContext(this);
    this.preferences = await dataPreferences.getPreferences(context, PREFS_FILE);

    // Load saved stats and unlocked status
    await this.loadProgress();

    // Update achievements with loaded status
    this.updateAchievementStatus();
  }

  private async loadProgress() {
    const statsJson = await this.preferences!.get(STATS_KEY, '{}') as string;
    this.playerStats = { ...this.playerStats, ...JSON.parse(statsJson) };

    const unlockedJson = await this.preferences!.get(ACHIEVEMENTS_KEY, '[]') as string;
    const unlockedIds = JSON.parse(unlockedJson);
    this.achievements.forEach(ach => {
      if (unlockedIds.includes(ach.id)) {
        ach.unlocked = true;
      }
    });
  }

  private async saveProgress() {
    await this.preferences!.put(STATS_KEY, JSON.stringify(this.playerStats));
    const unlockedIds = this.achievements.filter(a => a.unlocked).map(a => a.id);
    await this.preferences!.put(ACHIEVEMENTS_KEY, JSON.stringify(unlockedIds));
    await this.preferences!.flush();
  }

  private updateAchievementStatus() {
    // Logic to check all achievements based on current stats
    this.checkAchievement('first_win', this.playerStats.wins >= 1);
    this.checkAchievement('ten_wins', this.playerStats.wins >= 10);
    this.checkAchievement('quick_learner', this.playerStats.fastestWin <= 60);
    this.checkAchievement('flawless_victory', this.playerStats.flawlessWins > 0);
  }

  private checkAchievement(id: string, condition: boolean) {
    const achievement = this.achievements.find(a => a.id === id);
    if (achievement && !achievement.unlocked && condition) {
      achievement.unlocked = true;
      // Here you could trigger a notification for the newly unlocked achievement
    }
  }

  public async recordGameWin(time: number, flawless: boolean) {
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

// Create a single instance of the service to be used throughout the app
export const achievementService = new AchievementService();
