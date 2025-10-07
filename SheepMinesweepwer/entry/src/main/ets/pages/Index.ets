import { GameViewModel } from './viewModel/GameViewModel';
import { GameBoard } from './components/GameBoard';
import { LevelSelectScreen } from './components/LevelSelectScreen';
import { AchievementsScreen } from './components/AchievementsScreen';
import { AdventureMapScreen } from './components/AdventureMapScreen';
import { HexGamePage } from './HexGamePage';
import { CharacterSelectScreen } from './components/CharacterSelectScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { Level } from './model/Level';
import common from '@ohos.app.ability.common';
import { achievementService } from './services/AchievementService';
import { adventureService } from './services/AdventureService';
import { itemService } from './services/ItemService';
import { ThemeProvider, themeProvider } from './theme/ThemeProvider';
import { audioManager } from './services/AudioManager';

type GameState = 'character_select' | 'menu' | 'classic' | 'challenge_select' | 'challenge_game' | 'achievements' | 'adventure_map' | 'adventure_game' | 'hex_game' | 'settings';

@Entry
@Component
struct Index {
  @State viewModel: GameViewModel = new GameViewModel();
  @State gameState: GameState = 'character_select';
  @State selectedLevel: Level | null = null;
  @State provider: ThemeProvider = themeProvider;
  private context?: common.UIAbilityContext;

  aboutToAppear(): void {
    // 获取UIAbility上下文
    try {
      this.context = AppStorage.get<common.UIAbilityContext>('context');
    } catch (error) {
      console.error('Failed to get context:', error);
    }
    
    // 初始化所有服务和音频
    this.initializeServices();
  }

  aboutToDisappear(): void {
    // 清理所有资源
    this.cleanupResources();
  }

  private async initializeServices(): Promise<void> {
    // 初始化所有服务
    if (this.context) {
      try {
        await achievementService.init(this.context);
      } catch (error) {
        console.error('Failed to init AchievementService:', error);
      }
      
      try {
        await adventureService.init(this.context);
      } catch (error) {
        console.error('Failed to init AdventureService:', error);
      }
      
      try {
        await itemService.init(this.context);
      } catch (error) {
        console.error('Failed to init ItemService:', error);
      }
    }
    
    // 播放背景音乐
    try {
      await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
    } catch (error) {
      console.error('Failed to play BGM:', error);
    }
  }

  private async cleanupResources(): Promise<void> {
    // 释放音频资源
    try {
      await audioManager.release();
    } catch (error) {
      console.error('Failed to release audio manager:', error);
    }
    
    // 清理所有服务
    achievementService.destroy();
    adventureService.destroy();
    itemService.destroy();
  }

  private async playThemeMusic(): Promise<void> {
    try {
      await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
    } catch (error) {
      console.error('Failed to play theme music:', error);
    }
  }

  @Builder MainMenu() {
    Column({ space: 0 }) {
      // 顶部标题区域
      Column() {
        // 角色头像
        Image(this.provider.currentTheme.assets.avatar)
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 4, color: this.provider.currentTheme.colors.primary })
          .shadow({
            radius: 15,
            color: this.provider.currentTheme.colors.primary + '60',
            offsetX: 0,
            offsetY: 5
          })
          .margin({ bottom: 20 })
          .onError(() => {
            console.error('Failed to load avatar image');
          });

        Text('草原大作战')
          .fontSize(42)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.provider.currentTheme.colors.textPrimary)
          .textShadow({ radius: 3, color: '#00000030', offsetX: 2, offsetY: 2 })
          .margin({ bottom: 5 });

        Text('智斗灰太狼')
          .fontSize(24)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.provider.currentTheme.colors.textSecondary)
          .margin({ bottom: 30 });
      }
      .margin({ top: 60, bottom: 40 });

      // 主菜单按钮组
      Column({ space: 20 }) {
        this.MenuButton('经典模式', this.provider.currentTheme.colors.primary, () => {
          this.viewModel = new GameViewModel(null, this.context);
          this.gameState = 'classic';
        });

        this.MenuButton('挑战模式', this.provider.currentTheme.colors.secondary, () => {
          this.gameState = 'challenge_select';
        });

        this.MenuButton('冒险模式', this.provider.currentTheme.colors.primary, () => {
          this.gameState = 'adventure_map';
        });

        this.MenuButton('六边形模式', this.provider.currentTheme.colors.secondary, () => {
          this.gameState = 'hex_game';
        });

        this.MenuButton('成就殿堂', this.provider.currentTheme.colors.accent, () => {
          this.gameState = 'achievements';
        });

        this.MenuButton('更换角色', '#FF6B9D', () => {
          this.gameState = 'character_select';
        });

        this.MenuButton('游戏设置', '#9C27B0', () => {
          this.gameState = 'settings';
        });
      }
      .width('85%')
      .padding({ bottom: 40 });
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundImage(this.provider.currentTheme.assets.background)
    .backgroundImageSize(ImageSize.Cover);
  }

  @Builder MenuButton(text: string, bgColor: string, onClick: () => void) {
    Button(text)
      .width('100%')
      .height(65)
      .fontSize(22)
      .fontWeight(FontWeight.Medium)
      .backgroundColor(bgColor)
      .borderRadius(16)
      .shadow({
        radius: 10,
        color: '#00000030',
        offsetX: 0,
        offsetY: 5
      })
      .onClick(onClick)
      .stateStyles({
        pressed: {
          .scale({ x: 0.95, y: 0.95 })
        },
        normal: {
          .scale({ x: 1, y: 1 })
        }
      })
      .animation({ duration: 200, curve: Curve.EaseInOut });
  }

  @Builder GameView() {
    Column() {
      // 顶部状态栏 - 精美卡片设计
      Row() {
        // 地雷计数卡片
        Column() {
          Image(this.provider.currentTheme.assets.mineIcon)
            .width(35)
            .height(35)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: 5 });
          Text(`${this.viewModel.mineCount}`)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.provider.currentTheme.colors.textPrimary);
        }
        .width(100)
        .height(90)
        .backgroundColor(this.provider.currentTheme.colors.cardBg)
        .borderRadius(15)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 });

        Blank();

        // 状态显示卡片
        if (this.viewModel.gameOver) {
          Column() {
            Text(this.viewModel.gameWon ? '🎉' : '💥')
              .fontSize(32);
            Text(this.viewModel.gameWon ? '胜利！' : '失败！')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.viewModel.gameWon ? '#FFD700' : '#FF6B6B')
              .margin({ top: 5 });
          }
          .width(110)
          .height(90)
          .backgroundColor(this.viewModel.gameWon ? '#FFFACD' : '#FFE4E1')
          .borderRadius(15)
          .justifyContent(FlexAlign.Center)
          .shadow({ radius: 12, color: this.viewModel.gameWon ? '#FFD70060' : '#FF6B6B60', offsetX: 0, offsetY: 4 });
        }

        Blank();

        // 计时器卡片
        Column() {
          Text('⏱️')
            .fontSize(28)
            .margin({ bottom: 5 });
          Text(this.viewModel.getFormattedTime())
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.provider.currentTheme.colors.textPrimary);
        }
        .width(100)
        .height(90)
        .backgroundColor(this.provider.currentTheme.colors.cardBg)
        .borderRadius(15)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 });
      }
      .width('95%')
      .padding({ top: 15, bottom: 15, left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween);

      // 游戏棋盘
      GameBoard({ 
        viewModel: this.viewModel,
        provider: this.provider
      })
        .layoutWeight(1);

      // 底部按钮
      Row({ space: 20 }) {
        Button('新游戏')
          .width(150)
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.provider.currentTheme.colors.primary)
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.viewModel.initBoard();
          });

        Button('返回菜单')
          .width(150)
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF9800')
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.gameState = 'menu';
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 20, bottom: 25 });
    }
    .width('100%')
    .height('100%')
    .backgroundImage(this.provider.currentTheme.assets.background)
    .backgroundImageSize(ImageSize.Cover);
  }

  build() {
    Column() {
      if (this.gameState === 'character_select') {
        CharacterSelectScreen({
          provider: this.provider,
          onConfirm: (themeId: string) => {
            // 切换主题并播放新的背景音乐
            this.provider.setTheme(themeId);
            this.playThemeMusic();
            this.gameState = 'menu';
          },
          onBack: () => {
            this.gameState = 'menu';
          }
        });
      } else if (this.gameState === 'menu') {
        this.MainMenu();
      } else if (this.gameState === 'hex_game') {
        HexGamePage({ 
          provider: this.provider,
          onBack: () => this.gameState = 'menu' 
        });
      } else if (this.gameState === 'adventure_map') {
        AdventureMapScreen({ 
          provider: this.provider,
          onBack: () => this.gameState = 'menu' 
        });
      } else if (this.gameState === 'achievements') {
        AchievementsScreen({ 
          provider: this.provider,
          onBack: () => this.gameState = 'menu' 
        });
      } else if (this.gameState === 'settings') {
        SettingsScreen({
          provider: this.provider,
          onBack: () => this.gameState = 'menu'
        });
      } else if (this.gameState === 'challenge_select') {
        LevelSelectScreen({
          context: this.context,
          provider: this.provider,
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
    .width('100%')
    .height('100%');
  }
}
