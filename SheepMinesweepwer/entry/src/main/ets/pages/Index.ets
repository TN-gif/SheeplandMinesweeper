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
  @State magnifyingGlassCount: number = 3;  // 放大镜数量
  private context?: common.UIAbilityContext;

  aboutToAppear(): void {
    try {
      this.context = AppStorage.get<common.UIAbilityContext>('context');
    } catch (error) {
      console.error('Failed to get context:', error);
    }
    
    this.initializeServices();
    
    // 在选择小羊界面播放主页面背景音乐
    if (this.gameState === 'character_select') {
      console.log('[INIT] 选择小羊界面，开始播放主页面BGM');
      this.playMainBGM();
    }
  }

  aboutToDisappear(): void {
    this.cleanupResources();
  }

  private async initializeServices(): Promise<void> {
    if (this.context) {
      console.log('[INIT] 开始初始化音频服务');
      // ✅ 等待音频管理器初始化完成（包括加载保存的音量设置）
      await audioManager.setContext(this.context);
      
      // 检测音频设备（简化版）
      audioManager.checkAudioDevices();
      
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
        // 重置道具数量为默认值（修复本地存储中数量为0的问题）
        await itemService.resetInventory();
        // 初始化道具数量显示
        this.refreshItemCount();
      } catch (error) {
        console.error('Failed to init ItemService:', error);
      }
      
      try {
        console.log('[INIT] 尝试播放BGM');
        await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
        console.log('[INIT] BGM播放指令完成');
      } catch (error) {
        console.error('[INIT] BGM播放失败:', error);
      }
    }
  }

  // 刷新道具数量（每次都重新赋值以确保UI更新）
  private refreshItemCount(): void {
    const inventory = itemService.getInventory();
    const magnifyingGlass = inventory.find(item => item.id === 'magnifying_glass');
    if (magnifyingGlass) {
      this.magnifyingGlassCount = magnifyingGlass.quantity;
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

  // 播放主页面背景音乐
  private async playMainBGM(): Promise<void> {
    try {
      console.log('[BGM] 切换到主页面背景音乐');
      await audioManager.playBGM('music/Background/主页面背景音乐.mp3');
    } catch (error) {
      console.error('[BGM] 播放主页面BGM失败:', error);
    }
  }

  // 播放游戏页面背景音乐
  private async playGameBGM(): Promise<void> {
    try {
      console.log('[BGM] 切换到游戏页面背景音乐');
      await audioManager.playBGM('music/Background/游戏页面背景音乐.mp3');
    } catch (error) {
      console.error('[BGM] 播放游戏页面BGM失败:', error);
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
    Stack() {
      // 背景图片
      Image($rawfile('images/background/游戏背景.jpg'))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 返回按钮
      Stack() {
        Stack() {
          Column()
            .width(32)
            .height(32)
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(16);

          Image($rawfile('images/icon/返回.png'))
            .width(18)
            .height(20)
            .objectFit(ImageFit.Contain)
            .position({ x: 7, y: 6 });
        }
        .width(32)
        .height(32)
        .position({ x: 0, y: 0 });

        Text('返回')
          .width(51)
          .height(32)
          .fontSize(24)
          .fontWeight(400)
          .fontColor(Color.Black)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 42, y: 0 });
      }
      .width(93)
      .height(32)
      .position({ x: 18, y: 42 })
      .onClick(() => {
        if (this.previousGameState === 'adventure_map' && this.viewModel.gameWon) {
          adventureService.completeStage();
        }
        // 点击返回按钮，切换回主页面BGM
        this.gameState = this.previousGameState;
        this.playMainBGM();
      });

      // 地雷剩余数量卡片
      Stack() {
        Column()
          .width(91)
          .height(92)
          .backgroundColor('rgba(255, 255, 255, 0.85)')
          .borderRadius(12);

        // 灰太狼图标
        Image(this.provider.currentTheme.assets.mineIcon)
          .width(58)
          .height(51)
          .objectFit(ImageFit.Contain)
          .position({ x: 17, y: 10 });

        // 数量文字
        Text(`${this.viewModel.mineCount}`)
          .width(60)
          .height(22)
          .fontSize(20)
          .fontWeight(700)
          .lineHeight(22)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Center)
          .position({ x: 16, y: 62 });
      }
      .width(91)
      .height(92)
      .position({ x: 56, y: 89 });

      // 计时卡片
      Stack() {
        Column()
          .width(91)
          .height(92)
          .backgroundColor('rgba(255, 255, 255, 0.85)')
          .borderRadius(12);

        // 时钟图标
        Image($rawfile('images/icon/时钟.png'))
          .width(58)
          .height(51)
          .objectFit(ImageFit.Contain)
          .position({ x: 17, y: 10 });

        // 时间文字
          Text(this.viewModel.getFormattedTime())
          .width(80)
          .height(22)
          .fontSize(20)
          .fontWeight(700)
          .lineHeight(22)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Center)
          .position({ x: 6, y: 62 });
      }
      .width(91)
      .height(92)
      .position({ x: 212, y: 89 });

      // 放大镜道具卡片
      Stack() {
        Column()
          .width(283)
          .height(75)
          .backgroundColor(this.viewModel.selectedItem === 'magnifying_glass' ? 
            'rgba(100, 150, 200, 0.95)' : 'rgba(255, 255, 255, 0.85)')
          .borderRadius(12);

        // 放大镜图标
        Image($rawfile('images/icon/放大镜.png'))
          .width(58)
          .height(51)
          .objectFit(ImageFit.Contain)
          .position({ x: 17, y: 12 });

        // 数量 - 动态绑定
        Text(`×${this.magnifyingGlassCount}`)
          .width(32)
          .height(27)
          .fontSize(24)
          .fontWeight(700)
          .lineHeight(26)
          .fontColor(this.viewModel.selectedItem === 'magnifying_glass' ? Color.White : Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 86, y: 13 });

        // 标题
        Text('慢羊羊的放大镜')
          .width(147)
          .height(22)
          .fontSize(20)
          .fontWeight(700)
          .lineHeight(22)
          .fontColor(this.viewModel.selectedItem === 'magnifying_glass' ? Color.White : Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 86, y: 40 });

        // 说明文字
        Text('点击后可探测格子')
          .width(140)
          .height(16)
              .fontSize(14)
          .fontWeight(400)
          .lineHeight(15)
          .fontColor(this.viewModel.selectedItem === 'magnifying_glass' ? Color.White : 'rgba(0, 0, 0, 0.6)')
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 133, y: 17 });
      }
      .width(283)
      .height(75)
      .position({ x: 39, y: 207 })
      .onClick(() => {
        this.viewModel.selectItem('magnifying_glass');
      });

      // 棋盘容器
      Column() {
        GameBoard({ 
          viewModel: this.viewModel,
          provider: this.provider,
          onAfterAction: () => {
            this.refreshItemCount();
          }
        });
      }
      .width(308)
      .height(336)
      .position({ x: 26, y: 308 })
      .clip(true);

      // 底部导航栏
      this.GameNavBar();

      // 游戏结束弹窗
      if (this.viewModel.gameOver) {
        this.GameOverDialog();
      }
    }
    .width(360)
    .height(792);
  }

  // 游戏结束弹窗
  @Builder GameOverDialog() {
    // 半透明背景遮罩
    Stack() {
      Column()
        .width(360)
        .height(792)
        .backgroundColor('rgba(0, 0, 0, 0.5)');

      // 弹窗内容 - 参考白色按钮设计
      Stack() {
        // 白色背景
        Column()
          .width(280)
          .height(180)
          .backgroundColor(Color.White)
          .borderRadius(31);

        // 黑色边框
        Column()
          .width(288)
          .height(188)
          .backgroundColor(Color.Transparent)
          .borderRadius(35)
          .border({ width: 2, color: Color.Black })
          .position({ x: -4, y: -4 });

        // 文字内容
        Column({ space: 20 }) {
          // 消息文本
          Text(this.viewModel.gameWon ? '我一会再回来的！' : '没关系，你是最棒的小羊！')
            .fontSize(28)
            .fontWeight(400)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Center)
            .width('100%')
            .lineHeight(40);

          // 确定按钮
          Stack() {
            // 白色背景
            Column()
              .width(120)
              .height(52)
              .backgroundColor(Color.White)
              .borderRadius(26);

            // 黑色边框
            Column()
              .width(128)
              .height(60)
              .backgroundColor(Color.Transparent)
              .borderRadius(30)
              .border({ width: 2, color: Color.Black })
              .position({ x: -4, y: -4 });

            // 按钮文本
            Text('确定')
              .fontSize(24)
              .fontWeight(400)
              .fontColor(Color.Black)
              .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
              .textAlign(TextAlign.Center);
          }
          .width(120)
          .height(52)
          .onClick(() => {
            // 如果是冒险模式且游戏胜利，完成关卡
            if (this.previousGameState === 'adventure_map' && this.viewModel.gameWon) {
              adventureService.completeStage();
            }
            // 返回上一级菜单，切换回主页面BGM
            this.gameState = this.previousGameState;
            this.playMainBGM();
          });
        }
        .width(240)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center);
      }
      .width(280)
      .height(180)
      .position({ x: 40, y: 306 });
    }
    .width(360)
    .height(792)
    .position({ x: 0, y: 0 });
  }

  // 游戏页面底部导航栏
  @Builder GameNavBar() {
    Stack() {
      // 导航容器
      Stack() {
        // 成就标签
        this.GameNavTab('成就', 'images/icon/成就.png', 0, 0, 'achievements');

        // 游戏标签
        this.GameNavTab('游戏', 'images/icon/游戏.png', 119, 0, 'game');

        // 设置标签
        this.GameNavTab('设置', 'images/icon/设置.png', 238, 0, 'settings');
      }
      .width(350)
      .height(47)
      .position({ x: 5, y: 0 });
    }
    .width(360)
    .height(47)
    .position({ x: 0, y: 717 });
  }

  // 游戏页面导航标签
  @Builder GameNavTab(text: string, icon: string, x: number, y: number, tab: string) {
    Stack() {
      // 图标
      Image($rawfile(icon))
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
        .position({ x: 44, y: 0 });

      // 文本
      Text(text)
        .width(112)
        .height(19)
        .fontSize(18)
        .fontWeight(400)
        .lineHeight(20)
        .fontColor(tab === this.currentNavTab ? this.provider.currentTheme.colors.primary : Color.Black)
        .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
        .textAlign(TextAlign.Center)
        .position({ x: 0, y: 28 });
    }
    .width(112)
    .height(47)
    .position({ x: x, y: y })
    .onClick(() => {
      this.currentNavTab = tab;
      if (tab === 'achievements') {
        this.gameState = 'achievements';
      } else if (tab === 'game') {
        this.gameState = 'menu';
      } else if (tab === 'settings') {
        this.gameState = 'settings';
      }
    });
  }

  build() {
    Column() {
      if (this.gameState === 'character_select') {
        CharacterSelectScreen({
          provider: this.provider,
          onConfirm: (themeId: string) => {
            this.provider.setTheme(themeId);
            // 确认后回到主界面，播放主页面BGM
            this.playMainBGM();
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
            // 进入冒险游戏，播放游戏页面BGM
            this.playGameBGM();
          },
          onNavigate: (tab: string) => {
            if (tab === 'achievements') {
              this.gameState = 'achievements';
              this.currentNavTab = 'achievements';
            } else if (tab === 'game') {
              this.gameState = 'menu';
              this.currentNavTab = 'game';
            } else if (tab === 'settings') {
              this.gameState = 'settings';
              this.currentNavTab = 'settings';
            }
          }
        });
      } else if (this.gameState === 'achievements') {
        AchievementsScreen({ 
          provider: this.provider,
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onNavigate: (tab: string) => {
            if (tab === 'achievements') {
              this.gameState = 'achievements';
              this.currentNavTab = 'achievements';
            } else if (tab === 'game') {
              this.gameState = 'menu';
              this.currentNavTab = 'game';
            } else if (tab === 'settings') {
              this.gameState = 'settings';
              this.currentNavTab = 'settings';
            }
          }
        });
      } else if (this.gameState === 'settings') {
        SettingsScreen({
          provider: this.provider,
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onNavigate: (tab: string) => {
            if (tab === 'achievements') {
              this.gameState = 'achievements';
              this.currentNavTab = 'achievements';
            } else if (tab === 'game') {
              this.gameState = 'menu';
              this.currentNavTab = 'game';
            } else if (tab === 'settings') {
              this.gameState = 'settings';
              this.currentNavTab = 'settings';
            }
          },
          onSelectCharacter: () => {
            this.gameState = 'character_select';
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
            // 进入挑战游戏，播放游戏页面BGM
            this.playGameBGM();
          },
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onNavigate: (tab: string) => {
            if (tab === 'achievements') {
              this.gameState = 'achievements';
              this.currentNavTab = 'achievements';
            } else if (tab === 'game') {
              this.gameState = 'menu';
              this.currentNavTab = 'game';
            } else if (tab === 'settings') {
              this.gameState = 'settings';
              this.currentNavTab = 'settings';
            }
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
