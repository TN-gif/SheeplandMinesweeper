import { GameViewModel } from './viewModel/GameViewModel';
import { GameBoard } from './components/GameBoard';
// ... other component imports
import { LevelSelectScreen } from './components/LevelSelectScreen';
import { AchievementsScreen } from './components/AchievementsScreen';
import { AdventureMapScreen } from './components/AdventureMapScreen';
import { HexGamePage } from './HexGamePage'; // Import the new Hex Game Page
import { Level } from './model/Level';

// Add new states for adventure and hex modes
type GameState = 'menu' | 'classic' | 'challenge_select' | 'challenge_game' | 'achievements' | 'adventure_map' | 'adventure_game' | 'hex_game';

@Entry
@Component
struct Index {
  @State viewModel: GameViewModel = new GameViewModel();
  @State gameState: GameState = 'menu';

  @Builder MainMenu() {
    Column() {
      // ... (title)

      Button('经典模式').onClick(() => { /* ... */ });
      Button('挑战模式').onClick(() => { /* ... */ });
      Button('冒险模式').onClick(() => { this.gameState = 'adventure_map'; });

      // Add the Hex Mode button
      Button('六边形模式')
        .onClick(() => {
          this.gameState = 'hex_game';
        })
        .fontSize(24).margin(10).width('60%');

      Button('成就殿堂').onClick(() => { this.gameState = 'achievements'; });
    }
    .width('100%').height('100%').justifyContent(FlexAlign.Center);
  }

  @Builder GameView() {
    Column() {
      // Assuming you have the game board and controls defined elsewhere
      // Replace with your actual game view content
      Text('Placeholder for Game View')
    }
  }


  // The main build method that renders different screens based on gameState
  build() {
    Column() {
      if (this.gameState === 'menu') {
        this.MainMenu();
      } else if (this.gameState === 'hex_game') {
        HexGamePage({ onBack: () => this.gameState = 'menu' });
      } else if (this.gameState === 'adventure_map') {
        // ... (adventure map logic)
      } else if (this.gameState === 'achievements') {
        // ... (achievements logic)
      } else if (this.gameState === 'challenge_select') {
        // ... (challenge select logic)
      } else {
        // 'classic', 'challenge_game', and 'adventure_game' all use the main GameView
        this.GameView();
      }
    }
  }
}
