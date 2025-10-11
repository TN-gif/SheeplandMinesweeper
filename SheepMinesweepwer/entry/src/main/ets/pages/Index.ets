import { GameViewModel } from './viewModel/GameViewModel';
import { GameBoard } from './components/GameBoard';
import { LevelSelectScreen } from './components/LevelSelectScreen';
import { AchievementsScreen } from './components/AchievementsScreen';
import { AdventureMapScreen } from './components/AdventureMapScreen';
import { CharacterSelectScreen } from './components/CharacterSelectScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { Level } from './model/Level';
import common from '@ohos.app.ability.common';
import { achievementService } from './services/AchievementService';
import { adventureService } from './services/AdventureService';
import { itemService } from './services/ItemService';
import { ThemeProvider, themeProvider } from './theme/ThemeProvider';
import { audioManager } from './services/AudioManager';
import { FontManager } from './utils/FontManager';

type GameState = 'character_select' | 'menu' | 'classic' | 'challenge_select' | 'challenge_game' | 'achievements' | 'adventure_map' | 'adventure_game' | 'settings';

@Entry
@Component
struct Index {
  @State viewModel: GameViewModel = new GameViewModel();
  @State gameState: GameState = 'character_select';
  @State selectedLevel: Level | null = null;
  @State provider: ThemeProvider = themeProvider;
  @State previousGameState: GameState = 'menu';
  @State currentNavTab: string = 'game'; // 当前选中的导航标签：'achievements', 'game', 'settings'
  private context?: common.UIAbilityContext;

  aboutToAppear(): void {
    try {
      this.context = AppStorage.get<common.UIAbilityContext>('context');
    } catch (error) {
      console.error('Failed to get context:', error);
    }
    
    this.initializeServices();
  }

  aboutToDisappear(): void {
    this.cleanupResources();
  }

  private async initializeServices(): Promise<void> {
    if (this.context) {
      audioManager.setContext(this.context);
      
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
      
      try {
        await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
      } catch (error) {
        console.error('Failed to play BGM:', error);
      }
    }
  }

  private async cleanupResources(): Promise<void> {
    try {
      await audioManager.release();
    } catch (error) {
      console.error('Failed to release audio manager:', error);
    }
    
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

  // 主页面 - 按照设计文档精确实现
  @Builder MainMenu() {
    Stack() {
      // 背景图片 - 根据主题变化
      Image($rawfile(`images/background/${this.provider.currentTheme.name}.jpg`))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 容器 - 包含所有内容
      Stack() {
        // 标题文本 "草原大作战"
        Text('草原\n大作战')
          .width(321)
          .height(186)
          .fontSize(82)
          .fontWeight(400)
          .lineHeight(93)
          .textAlign(TextAlign.Center)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .position({ x: 20, y: 44 });

        // 模式选择区域
        Stack() {
          // 挑战模式按钮
          Stack() {
            // 白色背景
            Column()
              .width(134)
              .height(62)
              .backgroundColor(Color.White)
              .borderRadius(31);

            // 黑色边框矩形
            Column()
              .width(142)
              .height(70)
              .backgroundColor(Color.Transparent)
              .borderRadius(35)
              .border({ width: 2, color: Color.Black })
              .position({ x: -4, y: -4 });

            // 按钮文本
            Text('挑战模式')
              .width(112)
              .height(30)
              .fontSize(28)
              .fontWeight(400)
              .lineHeight(31)
              .textAlign(TextAlign.Center)
              .fontColor(Color.Black)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
              .position({ x: 11, y: 16 });
          }
          .width(134)
          .height(62)
          .position({ x: 0, y: 0 })
          .onClick(() => {
            this.gameState = 'challenge_select';
          });

          // 冒险模式按钮
          Stack() {
            // 白色背景
            Column()
              .width(134)
              .height(62)
              .backgroundColor(Color.White)
              .borderRadius(31);

            // 黑色边框矩形
            Column()
              .width(142)
              .height(70)
              .backgroundColor(Color.Transparent)
              .borderRadius(35)
              .border({ width: 2, color: Color.Black })
              .position({ x: -4, y: -4 });

            // 按钮文本
            Text('冒险模式')
              .width(112)
              .height(30)
              .fontSize(28)
              .fontWeight(400)
              .lineHeight(31)
              .textAlign(TextAlign.Center)
              .fontColor(Color.Black)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
              .position({ x: 11, y: 16 });
          }
          .width(134)
          .height(62)
          .position({ x: 174, y: 0 })
          .onClick(() => {
            this.gameState = 'adventure_map';
          });
        }
        .width(308)
        .height(62)
        .position({ x: 26, y: 607 });

        // 底部导航栏
        Stack() {
          // 导航容器
          Stack() {
            // 成就标签
            Stack() {
              // 成就图标
              Image($rawfile('images/icon/成就.png'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
                .position({ x: 44, y: 0 });

              // 成就文本
              Text('成就')
                .width(112)
                .height(19)
                .fontSize(18)
                .fontWeight(400)
                .lineHeight(20)
                .textAlign(TextAlign.Center)
                .fontColor(Color.Black)
                .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
                .position({ x: 0, y: 28 });
            }
            .width(112)
            .height(47)
            .position({ x: 0, y: 0 })
            .onClick(() => {
              this.currentNavTab = 'achievements';
              this.gameState = 'achievements';
            });

            // 游戏标签
            Stack() {
              // 游戏图标
              Image($rawfile('images/icon/游戏.png'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
                .position({ x: 44, y: 0 });

              // 游戏文本 - 使用主题色
              Text('游戏')
                .width(112)
                .height(19)
                .fontSize(18)
                .fontWeight(400)
                .lineHeight(20)
                .textAlign(TextAlign.Center)
                .fontColor(this.currentNavTab === 'game' ? this.provider.currentTheme.colors.primary : Color.Black)
                .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
                .position({ x: 0, y: 28 });
            }
            .width(112)
            .height(47)
            .position({ x: 119, y: 0 })
            .onClick(() => {
              this.currentNavTab = 'game';
              this.gameState = 'menu';
            });

            // 设置标签
            Stack() {
              // 设置图标
              Image($rawfile('images/icon/设置.png'))
                .width(24)
                .height(24)
                .objectFit(ImageFit.Contain)
                .position({ x: 44, y: 0 });

              // 设置文本
              Text('设置')
                .width(112)
                .height(16)
                .fontSize(18)
                .fontWeight(400)
                .lineHeight(20)
                .textAlign(TextAlign.Center)
                .fontColor(Color.Black)
                .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
                .position({ x: 0, y: 30 });
            }
            .width(112)
            .height(47)
            .position({ x: 238, y: 0 })
            .onClick(() => {
              this.currentNavTab = 'settings';
              this.gameState = 'settings';
            });
          }
          .width(350)
          .height(47)
          .position({ x: 5, y: 0 });
        }
        .width(360)
        .height(47)
        .position({ x: 0, y: 717 });
      }
      .width(360)
      .height(792);
    }
    .width(360)
    .height(792);
  }

  @Builder GameView() {
    Column() {
      // 顶部状态栏
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
            .fontColor(this.provider.currentTheme.colors.textPrimary)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`);
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
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
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
            .fontColor(this.provider.currentTheme.colors.textPrimary)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`);
        }
        .width(100)
        .height(90)
        .backgroundColor(this.provider.currentTheme.colors.cardBg)
        .borderRadius(15)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 });
      }
      .width('95%')
      .padding({ top: 20, bottom: 15, left: 10, right: 10 })
      .justifyContent(FlexAlign.SpaceBetween);

      // 道具栏
      Column() {
        Row({ space: 15 }) {
          // 放大镜道具
          Column() {
            Text('🔍')
              .fontSize(28)
              .margin({ bottom: 5 });
            Text('探测')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.viewModel.selectedItem === 'magnifying_glass' ? '#FFFFFF' : this.provider.currentTheme.colors.textPrimary)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`);
          }
          .width(90)
          .height(80)
          .backgroundColor(this.viewModel.selectedItem === 'magnifying_glass' ? 
            this.provider.currentTheme.colors.primary : 
            this.provider.currentTheme.colors.cardBg)
          .borderRadius(15)
          .justifyContent(FlexAlign.Center)
          .border({
            width: this.viewModel.selectedItem === 'magnifying_glass' ? 3 : 1.5,
            color: this.viewModel.selectedItem === 'magnifying_glass' ? this.provider.currentTheme.colors.primary : '#E0E0E0'
          })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.viewModel.selectItem('magnifying_glass');
          });

          // 铁拳道具
          Column() {
            Text('👊')
              .fontSize(28)
              .margin({ bottom: 5 });
            Text('强拆')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.viewModel.selectedItem === 'iron_fist' ? '#FFFFFF' : this.provider.currentTheme.colors.textPrimary)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`);
          }
          .width(90)
          .height(80)
          .backgroundColor(this.viewModel.selectedItem === 'iron_fist' ? 
            this.provider.currentTheme.colors.primary : 
            this.provider.currentTheme.colors.cardBg)
          .borderRadius(15)
          .justifyContent(FlexAlign.Center)
          .border({
            width: this.viewModel.selectedItem === 'iron_fist' ? 3 : 1.5,
            color: this.viewModel.selectedItem === 'iron_fist' ? this.provider.currentTheme.colors.primary : '#E0E0E0'
          })
          .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.viewModel.selectItem('iron_fist');
          });
        }
        .justifyContent(FlexAlign.Center);

        // 功能提示
        if (this.viewModel.selectedItem) {
          Text(this.viewModel.selectedItem === 'magnifying_glass' ? 
            '🔍 探测功能：点击任意格子，查看是否安全' : 
            '👊 强拆功能：点击任意格子，无论是否地雷都直接翻开')
            .fontSize(14)
            .fontColor(this.provider.currentTheme.colors.primary)
            .fontWeight(FontWeight.Medium)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Center)
            .margin({ top: 10 })
            .padding({ left: 15, right: 15, top: 8, bottom: 8 })
            .backgroundColor(this.provider.currentTheme.colors.primary + '20')
            .borderRadius(10);
        }
      }
      .width('100%')
      .padding({ left: 10, right: 10, bottom: 15 });

      // 游戏棋盘容器
      Column() {
        GameBoard({ 
          viewModel: this.viewModel,
          provider: this.provider
        });
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);

      // 底部按钮
      Row({ space: 20 }) {
        Button('新游戏')
          .width(150)
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
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
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .backgroundColor('#FF9800')
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            if (this.previousGameState === 'adventure_map' && this.viewModel.gameWon) {
              adventureService.completeStage();
            }
            this.gameState = this.previousGameState;
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 20, bottom: 30 });
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
            this.provider.setTheme(themeId);
            this.playThemeMusic();
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          }
        });
      } else if (this.gameState === 'menu') {
        this.MainMenu();
      } else if (this.gameState === 'adventure_map') {
        AdventureMapScreen({ 
          provider: this.provider,
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onSelectLevel: (level: Level) => {
            this.selectedLevel = level;
            this.viewModel = new GameViewModel(level, this.context);
            this.previousGameState = 'adventure_map';
            this.gameState = 'adventure_game';
          }
        });
      } else if (this.gameState === 'achievements') {
        AchievementsScreen({ 
          provider: this.provider,
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          }
        });
      } else if (this.gameState === 'settings') {
        SettingsScreen({
          provider: this.provider,
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          }
        });
      } else if (this.gameState === 'challenge_select') {
        LevelSelectScreen({
          context: this.context,
          provider: this.provider,
          onSelectLevel: (level: Level) => {
            this.selectedLevel = level;
            this.viewModel = new GameViewModel(level, this.context);
            this.previousGameState = 'challenge_select';
            this.gameState = 'challenge_game';
          },
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          }
        });
      } else {
        this.GameView();
      }
    }
    .width('100%')
    .height('100%');
  }
}
