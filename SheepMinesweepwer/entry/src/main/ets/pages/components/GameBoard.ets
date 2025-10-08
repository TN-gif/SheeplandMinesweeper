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
            .padding(2);
          }
        });
      });
    }
    .columnsTemplate('1fr '.repeat(this.viewModel.cols))
    .rowsTemplate('1fr '.repeat(this.viewModel.rows))
    .width('95%')
    .aspectRatio(1)
    .backgroundColor(this.provider.currentTheme.colors.background + 'CC')
    .borderRadius(20)
    .padding(10)
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
