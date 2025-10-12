/**
 * 应用主页面组件
 * 
 * 这是整个扫雷游戏的根组件，负责：
 * - 管理全局游戏状态（角色选择、主菜单、游戏界面等）
 * - 初始化所有核心服务（音频、成就、冒险、道具）
 * - 协调不同界面之间的切换
 * - 管理背景音乐的切换（主页面BGM vs 游戏页面BGM）
 * - 处理道具数量的显示和重置
 * 
 * 设计要点：
 * - 使用状态机模式管理界面切换
 * - 每个界面都是独立的子组件，通过回调通信
 * - 游戏开始时重置道具，结束时也重置，确保每局游戏体验一致
 * - BGM随界面切换自动更换，提升沉浸感
 */
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

/**
 * 游戏状态枚举类型
 * 
 * 定义应用的所有可能状态，用于界面切换。
 */
type GameState = 'character_select' | 'menu' | 'classic' | 'challenge_select' | 'challenge_game' | 'achievements' | 'adventure_map' | 'adventure_game' | 'settings';

/**
 * 主页面组件类
 * 
 * 应用的入口组件，使用@Entry装饰器标记。
 */
@Entry
@Component
struct Index {
  /** 游戏视图模型，管理游戏逻辑 */
  @State viewModel: GameViewModel = new GameViewModel();
  
  /** 当前游戏状态，控制显示哪个界面 */
  @State gameState: GameState = 'character_select';
  
  /** 当前选中的关卡配置 */
  @State selectedLevel: Level | null = null;
  
  /** 主题管理器实例 */
  @State provider: ThemeProvider = themeProvider;
  
  /** 上一个游戏状态，用于返回按钮 */
  @State previousGameState: GameState = 'menu';
  
  /** 当前选中的底部导航标签 */
  @State currentNavTab: string = 'game';
  
  /** 放大镜道具数量，用于UI显示 */
  @State magnifyingGlassCount: number = 3;
  
  /** 应用上下文，用于访问资源和服务 */
  private context?: common.UIAbilityContext;

  /**
   * 组件即将显示时的生命周期回调
   * 
   * 在此阶段完成：
   * - 获取全局context
   * - 初始化所有服务（音频、成就、冒险、道具）
   * - 播放主页面背景音乐
   */
  aboutToAppear(): void {
    try {
      this.context = AppStorage.get<common.UIAbilityContext>('context');
    } catch (error) {
      console.error('Failed to get context:', error);
    }
    
    // 初始化所有核心服务
    this.initializeServices();
    
    // 播放主页面背景音乐（角色选择界面）
    if (this.gameState === 'character_select') {
      console.log('[INIT] 选择小羊界面，开始播放主页面BGM');
      this.playMainBGM();
    }
  }

  /**
   * 组件即将销毁时的生命周期回调
   * 
   * 清理所有资源，释放服务引用。
   */
  aboutToDisappear(): void {
    this.cleanupResources();
  }

  /**
   * 初始化所有核心服务
   * 
   * 按顺序初始化：
   * 1. 音频管理器（包括加载保存的音量设置）
   * 2. 成就服务
   * 3. 冒险服务
   * 4. 道具服务（并重置道具数量）
   * 5. 播放初始BGM
   * 
   * 注意：所有初始化都包含错误处理，避免单个服务失败影响整体
   */
  private async initializeServices(): Promise<void> {
    if (this.context) {
      console.log('[INIT] 开始初始化音频服务');
      // 等待音频管理器初始化完成，包括加载保存的音量设置
      await audioManager.setContext(this.context);
      
      // 简单检测音频设备可用性
      audioManager.checkAudioDevices();
      
      // 初始化成就服务，加载成就配置和玩家进度
      try {
        await achievementService.init(this.context);
      } catch (error) {
        console.error('Failed to init AchievementService:', error);
      }
      
      // 初始化冒险服务，加载冒险地图和关卡配置
      try {
        await adventureService.init(this.context);
      } catch (error) {
        console.error('Failed to init AdventureService:', error);
      }
      
      // 初始化道具服务
      try {
        await itemService.init(this.context);
        // 重置道具数量为默认值，确保每次启动游戏有固定道具
        await itemService.resetInventory();
        // 刷新UI显示的道具数量
        this.refreshItemCount();
      } catch (error) {
        console.error('Failed to init ItemService:', error);
      }
      
      // 播放主题背景音乐
      try {
        console.log('[INIT] 尝试播放BGM');
        await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
        console.log('[INIT] BGM播放指令完成');
      } catch (error) {
        console.error('[INIT] BGM播放失败:', error);
      }
    }
  }

  /**
   * 刷新道具数量显示
   * 
   * 从道具服务获取最新数量并更新到UI状态。
   * 每次重新赋值以确保@State触发UI更新。
   */
  private refreshItemCount(): void {
    const inventory = itemService.getInventory();
    const magnifyingGlass = inventory.find(item => item.id === 'magnifying_glass');
    if (magnifyingGlass) {
      this.magnifyingGlassCount = magnifyingGlass.quantity;
    }
  }

  /**
   * 清理所有资源
   * 
   * 释放音频播放器，销毁各个服务实例。
   * 在组件销毁时调用，避免资源泄漏。
   */
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

  /**
   * 播放主题专属音乐
   * 
   * 根据当前选中的主题播放对应的背景音乐。
   * （目前所有主题使用相同BGM）
   */
  private async playThemeMusic(): Promise<void> {
    try {
      await audioManager.playBGM(this.provider.currentTheme.audio.bgm);
    } catch (error) {
      console.error('Failed to play theme music:', error);
    }
  }

  /**
   * 播放主页面背景音乐
   * 
   * 在主菜单、角色选择、关卡选择等非游戏界面播放。
   * 提供轻松愉快的氛围。
   */
  private async playMainBGM(): Promise<void> {
    try {
      console.log('[BGM] 切换到主页面背景音乐');
      await audioManager.playBGM('music/Background/主页面背景音乐.mp3');
    } catch (error) {
      console.error('[BGM] 播放主页面BGM失败:', error);
    }
  }

  /**
   * 播放游戏页面背景音乐
   * 
   * 在实际游戏界面播放，营造紧张刺激的游戏氛围。
   */
  private async playGameBGM(): Promise<void> {
    try {
      console.log('[BGM] 切换到游戏页面背景音乐');
      await audioManager.playBGM('music/Background/游戏页面背景音乐.mp3');
    } catch (error) {
      console.error('[BGM] 播放游戏页面BGM失败:', error);
    }
  }

  /**
   * 主菜单界面构建器
   * 
   * 构建主页面UI，包括：
   * - 主题专属背景图
   * - 标题"草原大作战"
   * - 挑战模式和冒险模式按钮
   * - 底部导航栏（成就、游戏、设置）
   * 
   * 设计严格按照UI设计文档实现，包括精确的尺寸和位置。
   */
  @Builder MainMenu() {
    Stack() {
      // 背景图：根据当前主题显示对应角色的背景
      Image($rawfile(`images/background/${this.provider.currentTheme.name}.jpg`))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 主内容容器
      Stack() {
        // 标题：竖排显示"草原大作战"
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

        // 游戏模式选择区域（挑战模式 + 冒险模式）
        Stack() {
          // 挑战模式按钮：提供不同难度的单局游戏
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
            // 进入关卡选择界面
            this.gameState = 'challenge_select';
          });

          // 冒险模式按钮：提供渐进式剧情关卡
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
            // 进入冒险地图界面
            this.gameState = 'adventure_map';
          });
        }
        .width(308)
        .height(62)
        .position({ x: 26, y: 607 });

        // 底部导航栏：成就、游戏、设置三个标签页
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

  /**
   * 游戏界面构建器
   * 
   * 构建游戏进行中的UI，包括：
   * - 游戏背景
   * - 返回按钮
   * - 地雷剩余数量显示
   * - 计时器显示
   * - 道具卡片（放大镜）
   * - 游戏棋盘
   * - 底部导航栏
   * - 游戏结束弹窗
   */
  @Builder GameView() {
    Stack() {
      // 游戏专用背景图
      Image($rawfile('images/background/游戏背景.jpg'))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 返回按钮：退出当前游戏，返回上一级菜单
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
      .onClick(async () => {
        // 如果是冒险模式且获胜，标记关卡完成
        if (this.previousGameState === 'adventure_map' && this.viewModel.gameWon) {
          adventureService.completeStage();
        }
        // 退出游戏时重置道具数量
        try {
          await itemService.resetInventory();
          this.refreshItemCount();
          console.log('[GameBack] 道具数量已重置');
        } catch (error) {
          console.error('[GameBack] 重置道具失败:', error);
        }
        // 返回上一级菜单，切换回主页面BGM
        this.gameState = this.previousGameState;
        this.playMainBGM();
      });

      // 地雷剩余数量显示卡片
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

      // 计时器显示卡片
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

      // 放大镜道具卡片：点击选中后可探测格子
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
        // 切换道具选中状态
        this.viewModel.selectItem('magnifying_glass');
      });

      // 游戏棋盘容器：显示扫雷格子
      Column() {
        GameBoard({ 
          viewModel: this.viewModel,
          provider: this.provider,
          onAfterAction: () => {
            // 使用道具后刷新数量显示
            this.refreshItemCount();
          }
        });
      }
      .width(308)
      .height(336)
      .position({ x: 26, y: 308 })
      .clip(true);

      // 游戏界面的底部导航栏
      this.GameNavBar();

      // 游戏结束弹窗：显示胜利或失败消息
      if (this.viewModel.gameOver) {
        this.GameOverDialog();
      }
    }
    .width(360)
    .height(792);
  }

  /**
   * 游戏结束弹窗构建器
   * 
   * 显示游戏结果（胜利/失败）和确定按钮。
   * 使用半透明遮罩和白色卡片样式。
   */
  @Builder GameOverDialog() {
    // 半透明黑色遮罩背景
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
          Text(this.viewModel.gameWon ? '灰太狼被弹飞啦！' : '没关系，你是最棒的小羊！')
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
          .onClick(async () => {
            // 冒险模式胜利时完成关卡
            if (this.previousGameState === 'adventure_map' && this.viewModel.gameWon) {
              adventureService.completeStage();
            }
            // 游戏结束后重置道具数量
            try {
              await itemService.resetInventory();
              this.refreshItemCount();
              console.log('[GameOver] 道具数量已重置');
            } catch (error) {
              console.error('[GameOver] 重置道具失败:', error);
            }
            // 返回上一级菜单，切换BGM
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

  /**
   * 游戏页面底部导航栏构建器
   * 
   * 包含成就、游戏、设置三个标签。
   */
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

  /**
   * 游戏页面导航标签构建器
   * 
   * 创建单个导航标签（图标+文字）。
   * 选中状态会高亮显示主题色。
   * 
   * @param {string} text - 标签文字
   * @param {string} icon - 图标路径
   * @param {number} x - X坐标
   * @param {number} y - Y坐标
   * @param {string} tab - 标签ID
   */
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
      // 切换当前选中标签
      this.currentNavTab = tab;
      // 根据标签ID切换游戏状态
      if (tab === 'achievements') {
        this.gameState = 'achievements';
      } else if (tab === 'game') {
        this.gameState = 'menu';
      } else if (tab === 'settings') {
        this.gameState = 'settings';
      }
    });
  }

  /**
   * 主构建方法
   * 
   * 根据当前gameState渲染对应的界面组件。
   * 这是一个状态机，每个状态对应一个完整的界面。
   * 
   * 状态流转示例：
   * character_select -> menu -> challenge_select -> challenge_game
   *                  -> menu -> adventure_map -> adventure_game
   */
  build() {
    Column() {
      // 角色选择界面：选择喜欢的小羊主题
      if (this.gameState === 'character_select') {
        CharacterSelectScreen({
          provider: this.provider,
          onConfirm: (themeId: string) => {
            // 切换到选中的主题
            this.provider.setTheme(themeId);
            // 播放主页面BGM
            this.playMainBGM();
            // 返回主菜单
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onBack: () => {
            // 取消选择，返回主菜单
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          }
        });
      } else if (this.gameState === 'menu') {
        // 主菜单界面
        this.MainMenu();
      } else if (this.gameState === 'adventure_map') {
        // 冒险地图界面：显示所有冒险关卡
        AdventureMapScreen({ 
          provider: this.provider,
          onBack: () => {
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onSelectLevel: async (level: Level) => {
            // 开始新游戏前重置道具数量
            try {
              await itemService.resetInventory();
              this.refreshItemCount();
              console.log('[NewGame] 冒险模式：道具数量已重置');
            } catch (error) {
              console.error('[NewGame] 重置道具失败:', error);
            }
            // 创建新的游戏实例
            this.selectedLevel = level;
            this.viewModel = new GameViewModel(level, this.context);
            this.previousGameState = 'adventure_map';
            this.gameState = 'adventure_game';
            // 进入游戏，切换到游戏BGM
            this.playGameBGM();
          },
          onNavigate: (tab: string) => {
            // 底部导航栏切换
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
        // 成就界面：显示玩家获得的成就
        AchievementsScreen({ 
          provider: this.provider,
          onBack: () => {
            // 返回主菜单
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onNavigate: (tab: string) => {
            // 底部导航栏切换
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
        // 设置界面：音量调节、角色切换等
        SettingsScreen({
          provider: this.provider,
          onBack: () => {
            // 返回主菜单
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onNavigate: (tab: string) => {
            // 底部导航栏切换
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
            // 打开角色选择界面
            this.gameState = 'character_select';
          }
        });
      } else if (this.gameState === 'challenge_select') {
        // 挑战关卡选择界面：显示不同难度的关卡
        LevelSelectScreen({
          context: this.context,
          provider: this.provider,
          onSelectLevel: async (level: Level) => {
            // 开始新游戏前重置道具数量
            try {
              await itemService.resetInventory();
              this.refreshItemCount();
              console.log('[NewGame] 挑战模式：道具数量已重置');
            } catch (error) {
              console.error('[NewGame] 重置道具失败:', error);
            }
            // 创建新的游戏实例
            this.selectedLevel = level;
            this.viewModel = new GameViewModel(level, this.context);
            this.previousGameState = 'challenge_select';
            this.gameState = 'challenge_game';
            // 进入游戏，切换到游戏BGM
            this.playGameBGM();
          },
          onBack: () => {
            // 返回主菜单
            this.gameState = 'menu';
            this.currentNavTab = 'game';
          },
          onNavigate: (tab: string) => {
            // 底部导航栏切换
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
        // 其他状态（challenge_game, adventure_game）：显示游戏界面
        this.GameView();
      }
    }
    .width('100%')
    .height('100%');
  }
}
