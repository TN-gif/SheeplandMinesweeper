import { GameViewModel } from './viewModel/GameViewModel';
import { GameBoard } from './components/GameBoard';
import { LevelSelectScreen } from './components/LevelSelectScreen';
import { AchievementsScreen } from './components/AchievementsScreen';
import { AdventureMapScreen } from './components/AdventureMapScreen';
import { HexGamePage } from './HexGamePage';
import { Level } from './model/Level';
import common from '@ohos.app.ability.common';
import { achievementService } from './services/AchievementService';
import { adventureService } from './services/AdventureService';
import { itemService } from './services/ItemService';

type GameState = 'menu' | 'classic' | 'challenge_select' | 'challenge_game' | 'achievements' | 'adventure_map' | 'adventure_game' | 'hex_game';

@Entry
@Component
struct Index {
  @State viewModel: GameViewModel = new GameViewModel();
  @State gameState: GameState = 'menu';
  @State selectedLevel: Level | null = null;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    // 初始化所有服务
    achievementService.init(this.context);
    adventureService.init(this.context);
    itemService.init(this.context);
  }

  @Builder MainMenu() {
    Column({ space: 20 }) {
      Text('草原大作战：智斗灰太狼')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E7D32')
        .margin({ bottom: 20 });

      Button('经典模式')
        .width('80%')
        .fontSize(20)
        .backgroundColor('#4CAF50')
        .onClick(() => {
          this.viewModel = new GameViewModel(null, this.context);
          this.gameState = 'classic';
        });
      Button('挑战模式')
        .width('80%')
        .fontSize(20)
        .backgroundColor('#4CAF50')
        .onClick(() => { this.gameState = 'challenge_select'; });
      Button('冒险模式')
        .width('80%')
        .fontSize(20)
        .backgroundColor('#4CAF50')
        .onClick(() => { this.gameState = 'adventure_map'; });
      Button('六边形模式')
        .width('80%')
        .fontSize(20)
        .backgroundColor('#4CAF50')
        .onClick(() => { this.gameState = 'hex_game'; });
      Button('成就殿堂')
        .width('80%')
        .fontSize(20)
        .backgroundColor('#FFD700')
        .onClick(() => { this.gameState = 'achievements'; });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#E8F5E9');
  }

  @Builder GameView() {
    Column() {
      // 顶部状态栏
      Row() {
        Text(`🐺 地雷: ${this.viewModel.mineCount}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White);
        
        Blank();
        
        if (this.viewModel.gameOver) {
          Text(this.viewModel.gameWon ? '🎉 胜利！' : '💥 失败！')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.viewModel.gameWon ? '#FFD700' : '#FF6B6B');
        }
        
        Blank();
        
        Text('⏱️ 计时器')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White);
      }
      .width('100%')
      .padding(15)
      .backgroundColor('#4CAF50');

      // 游戏棋盘
      GameBoard({ viewModel: this.viewModel })
        .layoutWeight(1)
        .padding(10);

      // 底部按钮
      Row({ space: 15 }) {
        Button('新游戏')
          .fontSize(18)
          .backgroundColor('#2E7D32')
          .onClick(() => {
            this.viewModel.initBoard();
          });
        
        Button('返回菜单')
          .fontSize(18)
          .backgroundColor('#FF9800')
          .onClick(() => {
            this.gameState = 'menu';
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding(15);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#E8F5E9');
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
          context: this.context,
          onSelectLevel: (level: Level) => {
            this.selectedLevel = level;
            this.viewModel = new GameViewModel(level, this.context);
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
