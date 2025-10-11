/**
 * 游戏页面 - 完整的游戏界面
 * 包含棋盘、HUD、道具栏等所有游戏元素
 */
import { GameViewModel } from '../viewModel/GameViewModel';
import { CellComponent } from './CellComponent';
import { Cell } from '../model/Cell';
import { ThemeProvider } from '../theme/ThemeProvider';
import { FontManager } from '../utils/FontManager';

@Component
export struct GameScreen {
  @ObjectLink viewModel: GameViewModel;
  @ObjectLink provider: ThemeProvider;
  @State boardScale: number = 1.0;
  @State boardOffsetX: number = 0;
  @State boardOffsetY: number = 0;
  @State currentNavTab: string = 'game';
  @State currentTime: number = 0;
  onBack: () => void = () => {};
  onNavigate: (tab: string) => void = () => {};
  
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });
  private readonly CELL_SIZE: number = 38;
  private readonly CELL_PADDING: number = 2;
  private readonly BOARD_PADDING: number = 10;
  private timerId: number = -1;

  aboutToAppear(): void {
    // 启动计时器
    this.currentTime = 0;
    this.timerId = setInterval(() => {
      if (!this.viewModel.gameWon && !this.viewModel.gameLost) {
        this.currentTime++;
      }
    }, 1000);
  }

  aboutToDisappear(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private getBoardWidth(): number {
    return this.viewModel.cols * (this.CELL_SIZE + this.CELL_PADDING * 2) + this.BOARD_PADDING * 2;
  }

  private getBoardHeight(): number {
    return this.viewModel.rows * (this.CELL_SIZE + this.CELL_PADDING * 2) + this.BOARD_PADDING * 2;
  }

  private formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  build() {
    Stack() {
      // 背景图片
      Image($rawfile('images/background/游戏背景.jpg'))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover);

      // 返回按钮
      Stack() {
        // 返回组合
        Stack() {
          Column()
            .width(32)
            .height(32)
            .backgroundColor(Color.White)
            .borderRadius(16);

          Image($rawfile('images/icon/返回.png'))
            .width(19)
            .height(18)
            .objectFit(ImageFit.Contain)
            .position({ x: 7, y: 7 });
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
      .onClick(this.onBack);

      // 地雷剩余数量
      Stack() {
        Column()
          .width(91)
          .height(92)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .borderRadius(12);

        // 容器1
        Stack() {
          // 灰太狼图标
          Image($rawfile('images/icon/灰太狼.jpg'))
            .width(58)
            .height(51)
            .objectFit(ImageFit.Contain)
            .position({ x: 0, y: 0 });

          // 数量文字
          Text(`${this.viewModel.getMinesRemaining()}`)
            .width(58)
            .height(24)
            .fontSize(20)
            .fontWeight(400)
            .lineHeight(22)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Center)
            .position({ x: 0, y: 53 });
        }
        .width(58)
        .height(77)
        .position({ x: 17, y: 8 });
      }
      .width(91)
      .height(92)
      .position({ x: 56, y: 89 });

      // 计时功能
      Stack() {
        Column()
          .width(91)
          .height(92)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .borderRadius(12);

        // 容器1
        Stack() {
          // 时钟图标
          Image($rawfile('images/icon/时钟.png'))
            .width(58)
            .height(51)
            .objectFit(ImageFit.Contain)
            .position({ x: 0, y: 0 });

          // 时间文字
          Text(this.formatTime(this.currentTime))
            .width(63)
            .height(24)
            .fontSize(20)
            .fontWeight(400)
            .lineHeight(22)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Center)
            .position({ x: -2, y: 53 });
        }
        .width(58)
        .height(77)
        .position({ x: 17, y: 8 });
      }
      .width(91)
      .height(92)
      .position({ x: 212, y: 89 });

      // 道具功能 - 放大镜
      Stack() {
        Column()
          .width(283)
          .height(75)
          .backgroundColor('rgba(255, 255, 255, 0.2)')
          .borderRadius(12);

        // 图标区域
        Stack() {
          // 放大镜图标
          Image($rawfile('images/icon/放大镜.png'))
            .width(58)
            .height(51)
            .objectFit(ImageFit.Contain)
            .position({ x: 0, y: 0 });

          // 数量标记
          Text('×3')
            .width(43)
            .height(43)
            .fontSize(24)
            .fontWeight(400)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 58, y: 4 });
        }
        .width(85)
        .height(51)
        .position({ x: 17, y: 12 });

        // 文字描述
        Stack() {
          Text('慢羊羊的放大镜')
            .width(157)
            .height(24)
            .fontSize(20)
            .fontWeight(400)
            .lineHeight(22)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 0, y: 0 });

          Text('可查看任意格子是否安全')
            .width(157)
            .height(24)
            .fontSize(14)
            .fontWeight(400)
            .lineHeight(16)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .textAlign(TextAlign.Start)
            .position({ x: 0, y: 27 });
        }
        .width(157)
        .height(51)
        .position({ x: 109, y: 12 });
      }
      .width(283)
      .height(75)
      .position({ x: 39, y: 207 })
      .onClick(() => {
        this.viewModel.selectItem('magnifying_glass');
      });

      // 棋盘区域
      Stack() {
        Column()
          .width(308)
          .height(336)
          .backgroundColor('rgba(233, 243, 219, 1)')
          .borderRadius(12);

        // 棋盘Grid
        Grid() {
          ForEach(this.viewModel.board || [], (row: Cell[], rowIndex: number) => {
            ForEach(row || [], (cell: Cell, colIndex: number) => {
              if (cell) {
                GridItem() {
                  CellComponent({
                    cell: cell,
                    provider: this.provider,
                    onReveal: (x: number, y: number): void => this.viewModel.revealCell(x, y),
                    onFlag: (x: number, y: number): void => this.viewModel.flagCell(x, y),
                    onChord: (x: number, y: number): void => this.viewModel.chordCell(x, y)
                  });
                }
                .width(this.CELL_SIZE)
                .height(this.CELL_SIZE)
                .padding(this.CELL_PADDING);
              }
            });
          });
        }
        .columnsTemplate('1fr '.repeat(this.viewModel.cols))
        .rowsTemplate('1fr '.repeat(this.viewModel.rows))
        .width(this.getBoardWidth())
        .height(this.getBoardHeight())
        .borderRadius(12)
        .padding(this.BOARD_PADDING)
        .scale({ x: this.boardScale, y: this.boardScale })
        .translate({ x: this.boardOffsetX, y: this.boardOffsetY })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            // 双指缩放
            PinchGesture()
              .onActionUpdate((event: GestureEvent) => {
                if (event && event.scale) {
                  this.boardScale = Math.max(0.5, Math.min(3.0, event.scale));
                }
              }),
            // 拖拽
            PanGesture(this.panOption)
              .onActionUpdate((event: GestureEvent) => {
                if (event) {
                  this.boardOffsetX = event.offsetX;
                  this.boardOffsetY = event.offsetY;
                }
              })
          )
        )
        .position({ x: (308 - this.getBoardWidth()) / 2, y: (336 - this.getBoardHeight()) / 2 });
      }
      .width(308)
      .height(336)
      .position({ x: 26, y: 308 });

      // 底部导航栏
      this.BottomNavBar();
    }
    .width(360)
    .height(792);
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
        .fontColor(tab === 'game' ? this.provider.currentTheme.colors.primary : Color.Black)
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

