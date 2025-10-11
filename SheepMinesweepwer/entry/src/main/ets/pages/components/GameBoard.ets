import { GameViewModel } from '../viewModel/GameViewModel';
import { CellComponent } from './CellComponent';
import { Cell } from '../model/Cell';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct GameBoard {
  @ObjectLink viewModel: GameViewModel;
  @ObjectLink provider: ThemeProvider;
  @State boardScale: number = 1.0;
  @State boardOffsetX: number = 0;
  @State boardOffsetY: number = 0;
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });
  
  // 固定格子大小（9x9模式下的标准大小）
  private readonly CELL_SIZE: number = 38;
  private readonly CELL_PADDING: number = 2;
  private readonly BOARD_PADDING: number = 10;

  // 计算棋盘实际宽度和高度
  private getBoardWidth(): number {
    return this.viewModel.cols * (this.CELL_SIZE + this.CELL_PADDING * 2) + this.BOARD_PADDING * 2;
  }

  private getBoardHeight(): number {
    return this.viewModel.rows * (this.CELL_SIZE + this.CELL_PADDING * 2) + this.BOARD_PADDING * 2;
  }

  build() {
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
    .backgroundColor(this.provider.currentTheme.colors.background + 'CC')
    .borderRadius(20)
    .padding(this.BOARD_PADDING)
    .shadow({
      radius: 20,
      color: '#00000030',
      offsetX: 0,
      offsetY: 10
    })
    .scale({ x: this.boardScale, y: this.boardScale })
    .translate({ x: this.boardOffsetX, y: this.boardOffsetY })
    .gesture(
      GestureGroup(GestureMode.Parallel,
        // 双指缩放手势
        PinchGesture()
          .onActionStart((event: GestureEvent) => {
            console.log('Pinch start');
          })
          .onActionUpdate((event: GestureEvent) => {
            if (event && event.scale) {
              this.boardScale = Math.max(0.5, Math.min(3.0, event.scale));
            }
          })
          .onActionEnd((event: GestureEvent) => {
            console.log('Pinch end: boardScale = ' + this.boardScale);
          }),
        // 拖拽手势
        PanGesture(this.panOption)
          .onActionStart((event: GestureEvent) => {
            console.log('Pan start');
          })
          .onActionUpdate((event: GestureEvent) => {
            if (event) {
              this.boardOffsetX = event.offsetX;
              this.boardOffsetY = event.offsetY;
            }
          })
          .onActionEnd((event: GestureEvent) => {
            console.log('Pan end');
          })
      )
    );
  }
}
