import { GameViewModel } from './viewModel/GameViewModel';
import { GameBoard } from './components/GameBoard';
import { LevelSelectScreen } from './components/LevelSelectScreen';
import { AchievementsScreen } from './components/AchievementsScreen';
import { AdventureMapScreen } from './components/AdventureMapScreen';
import { HexGamePage } from './HexGamePage';
import { Level } from './model/Level';

type GameState = 'menu' | 'classic' | 'challenge_select' | 'challenge_game' | 'achievements' | 'adventure_map' | 'adventure_game' | 'hex_game';

@Entry
@Component
struct Index {
  @State viewModel: GameViewModel = new GameViewModel();
  @State gameState: GameState = 'menu';
  @State selectedLevel: Level | null = null;

  @Builder MainMenu() {
    Column() {
      Button('经典模式').onClick(() => {
        this.viewModel = new GameViewModel();
        this.gameState = 'classic';
      });
      Button('挑战模式').onClick(() => { this.gameState = 'challenge_select'; });
      Button('冒险模式').onClick(() => { this.gameState = 'adventure_map'; });
      Button('六边形模式').onClick(() => { this.gameState = 'hex_game'; });
      Button('成就殿堂').onClick(() => { this.gameState = 'achievements'; });
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center);
  }

  @Builder GameView() {
    Column() {
      GameBoard({ viewModel: this.viewModel });
    }
  }

  build() {
    Column() {
      if (this.gameState === 'menu') {
        this.MainMenu();
      } else if (this.gameState === 'hex_game') {
        HexGamePage({ onBack: () => this.gameState = 'menu' });
      } else if (this.gameState === 'adventure_map') {
        AdventureMapScreen({ onBack: () => this.gameState = 'menu' });
      } else if (this.gameState === 'achievements') {
        AchievementsScreen({ onBack: () => this.gameState = 'menu' });
      } else if (this.gameState === 'challenge_select') {
        LevelSelectScreen({
          onSelectLevel: (level: Level) => {
            this.selectedLevel = level;
            this.viewModel = new GameViewModel(level);
            this.gameState = 'challenge_game';
          },
          onBack: () => { this.gameState = 'menu'; }
        });
      } else {
        this.GameView();
      }
    }
  }
}
