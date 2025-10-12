import { Level } from '../model/Level';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';
import { FontManager } from '../utils/FontManager';
import util from '@ohos.util';

// 定义JSON数据接口
interface LevelJsonData {
  levelId: string;
  name: string;
  rows: number;
  cols: number;
  mines: number;
  isUnlocked: boolean;
}

@Component
export struct LevelSelectScreen {
  @State levels: Level[] = [];
  @ObjectLink provider: ThemeProvider;
  @State showingMode: 'challenge' | 'custom' = 'challenge';
  @State currentNavTab: string = 'game';
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};
  onNavigate: (tab: string) => void = () => {};
  context?: common.UIAbilityContext;
  
  // 自定义关卡参数
  @State customRows: string = '10';
  @State customCols: string = '10';
  @State customMines: string = '15';

  async aboutToAppear(): Promise<void> {
    if (!this.context) {
      console.error('Context is not provided to LevelSelectScreen');
      return;
    }
    try {
      const rawFile: Uint8Array = await this.context.resourceManager.getRawFileContent('levels.json');
      const textDecoder = util.TextDecoder.create('utf-8');
      const jsonString: string = textDecoder.decodeToString(rawFile);
      const levelsData = JSON.parse(jsonString) as LevelJsonData[];
      // 转换为Level实例
      this.levels = levelsData.map((data: LevelJsonData) => new Level(
        data.levelId,
        data.name,
        data.rows,
        data.cols,
        data.mines,
        data.isUnlocked
      ));
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to load levels: ${error.message}, code: ${error.code}`);
    }
  }

  build() {
    Stack() {
      // 背景图片 - 随主题变化
      Image(this.provider.currentTheme.assets.background)
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 根据模式显示不同页面
      if (this.showingMode === 'challenge') {
        this.ChallengeMode();
      } else {
        this.CustomMode();
      }

      // 底部导航栏
      this.BottomNavBar();
    }
    .width(360)
    .height(792);
  }

  // 挑战模式页面
  @Builder ChallengeMode() {
    Stack() {
      // 返回按钮
      Stack() {
        // 返回组合
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

        Text('返回菜单')
          .width(99)
          .height(32)
          .fontSize(24)
          .fontWeight(400)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 42, y: 0 });
      }
      .width(141)
      .height(32)
      .position({ x: 18, y: 42 })
      .onClick(this.onBack);

      // 容器2
      Stack() {
        // 挑战模式标题
        Text('挑战模式')
          .width(306)
          .height(75)
          .fontSize(75)
          .fontWeight(400)
          .lineHeight(83)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 0, y: 0 });

        // 容器1 - 关卡列表（动态渲染）
        Stack() {
          ForEach(this.levels.slice(0, 3), (level: Level, index: number) => {
            this.LevelCard(level, 0, index * 136);
          });
        }
        .width(291)
        .height(387)
        .position({ x: 8, y: 107 });

        // 自定义模式按钮
        Stack() {
          // 白色背景
          Column()
            .width(217)
            .height(58)
            .backgroundColor(Color.White)
            .borderRadius(29);

          // 黑色边框矩形
          Column()
            .width(225)
            .height(66)
            .backgroundColor(Color.Transparent)
            .borderRadius(33)
            .border({ width: 2, color: Color.Black })
            .position({ x: -4, y: -4 });

          // 按钮文本
          Text('自定义模式')
            .width(155)
            .height(34)
            .fontSize(31)
            .fontWeight(400)
            .lineHeight(34)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Center)
            .position({ x: 31, y: 12 });
        }
        .width(217)
        .height(58)
        .position({ x: 45, y: 526 })
        .onClick(() => {
          this.showingMode = 'custom';
        });
      }
      .width(306)
      .height(584)
      .position({ x: 27, y: 92 });
    }
    .width(360)
    .height(792);
  }

  // 关卡卡片Builder
  @Builder LevelCard(level: Level, x: number, y: number) {
    Stack() {
      // Dialog/BG 白色半透明背景
      Column()
        .width(291)
        .height(115)
        .backgroundColor('rgba(255, 255, 255, 0.85)')
        .borderRadius(20);

      // 文字区域
      Stack() {
        // 标题
        Text(level.name)
          .width(243)
          .height(42)
          .fontSize(36)
          .fontWeight(400)
          .lineHeight(40)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 0, y: 0 });

        // 副标题
        Text(`${level.rows} × ${level.cols} | ${level.mines}个灰太狼`)
          .width(243)
          .height(23)
          .fontSize(18)
          .fontWeight(400)
          .lineHeight(20)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 0, y: 52 });
      }
      .width(243)
      .height(75)
      .position({ x: 24, y: 20 });
    }
    .width(291)
    .height(115)
    .position({ x: x, y: y })
    .onClick(() => {
      this.onSelectLevel(level);
    });
  }

  // 自定义模式页面
  @Builder CustomMode() {
    Stack() {
      // 返回按钮
      Stack() {
        // 返回组合
        Stack() {
          Column()
            .width(32)
            .height(32)
            .backgroundColor('rgba(255, 255, 255, 0.9)')
            .borderRadius(16);

          Image($rawfile('images/icon/返回.png'))
            .width(20)
            .height(19)
            .objectFit(ImageFit.Contain)
            .position({ x: 6, y: 6 });
        }
        .width(32)
        .height(32)
        .position({ x: 0, y: 0 });

        Text('返回挑战')
          .width(99)
          .height(32)
          .fontSize(24)
          .fontWeight(400)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Start)
          .position({ x: 42, y: 0 });
      }
      .width(141)
      .height(32)
      .position({ x: 18, y: 42 })
      .onClick(() => {
        this.showingMode = 'challenge';
      });

      // 自定义模式标题
      Text('自定义模式')
        .width(306)
        .height(75)
        .fontSize(60)
        .fontWeight(400)
        .lineHeight(66)
        .fontColor(Color.Black)
        .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
        .textAlign(TextAlign.Start)
        .position({ x: 27, y: 92 });

      // 容器7 - 输入区域
      Stack() {
        Column()
          .width(291)
          .height(365)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .borderRadius(20);

        // 容器6
        Stack() {
      // 行数输入
          this.InputField('棋盘行数（5-30）', this.customRows, 0, 0, (value: string) => {
            this.customRows = value;
          });

      // 列数输入
          this.InputField('棋盘列数（5-30）', this.customCols, 0, 104, (value: string) => {
            this.customCols = value;
          });

          // 地雷数量输入
          this.InputField('灰太狼数量', this.customMines, 0, 208, (value: string) => {
            this.customMines = value;
          });
        }
        .width(243)
        .height(287)
        .position({ x: 24, y: 39 });
      }
      .width(291)
      .height(365)
      .position({ x: 35, y: 192 });

      // 开始游戏按钮
      Stack() {
        // 白色背景
        Column()
          .width(217)
          .height(58)
          .backgroundColor(Color.White)
          .borderRadius(29);

        // 黑色边框矩形
        Column()
          .width(225)
          .height(66)
          .backgroundColor(Color.Transparent)
          .borderRadius(33)
          .border({ width: 2, color: Color.Black })
          .position({ x: -4, y: -4 });

        // 按钮文本
        Text('开始游戏')
          .width(124)
          .height(34)
          .fontSize(31)
          .fontWeight(400)
          .lineHeight(34)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .textAlign(TextAlign.Center)
          .position({ x: 47, y: 12 });
      }
      .width(217)
      .height(58)
      .position({ x: 72, y: 613 })
          .onClick(() => {
            const rows = parseInt(this.customRows);
            const cols = parseInt(this.customCols);
            const mines = parseInt(this.customMines);

            // 验证输入
            if (rows >= 5 && rows <= 30 && cols >= 5 && cols <= 30 && mines > 0 && mines < rows * cols) {
              const customLevel: Level = new Level(
                'custom',
                '自定义关卡',
                rows,
                cols,
                mines,
                true
              );
          this.showingMode = 'challenge';
              this.onSelectLevel(customLevel);
            } else {
              console.error('Invalid custom level parameters');
            }
          });
      }
    .width(360)
    .height(792);
  }

  // 输入框Builder
  @Builder InputField(label: string, value: string, x: number, y: number, onChange: (value: string) => void) {
    Stack() {
      // 标签
      Text(label)
        .width(243)
        .height(42)
        .fontSize(30)
        .fontWeight(400)
        .lineHeight(33)
        .fontColor(Color.Black)
        .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
        .textAlign(TextAlign.Start)
        .position({ x: 0, y: 0 });

      // 输入框
      Stack() {
        Column()
          .width(230)
          .height(36)
          .backgroundColor(Color.White)
          .borderRadius(4);

        TextInput({ text: value })
          .type(InputType.Number)
          .fontSize(20)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .onChange(onChange)
          .width(230)
          .height(36)
          .backgroundColor(Color.Transparent)
          .padding({ left: 8, right: 8 });
      }
      .width(230)
      .height(36)
      .position({ x: 0, y: 43 });
    }
    .width(243)
    .height(79)
    .position({ x: x, y: y });
  }

  // 底部导航栏
  @Builder BottomNavBar() {
    Stack() {
      // 导航容器
      Stack() {
        // 成就标签
        this.NavTab('成就', 'images/icon/成就.png', 0, 0, 'achievements');

        // 游戏标签
        this.NavTab('游戏', 'images/icon/游戏.png', 119, 0, 'game');

        // 设置标签
        this.NavTab('设置', 'images/icon/设置.png', 238, 0, 'settings');
      }
      .width(350)
      .height(47)
      .position({ x: 5, y: 0 });
    }
    .width(360)
    .height(47)
    .position({ x: 0, y: 717 });
  }

  // 导航标签Builder
  @Builder NavTab(text: string, icon: string, x: number, y: number, tab: string) {
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
      this.onNavigate(tab);
    });
  }
}
