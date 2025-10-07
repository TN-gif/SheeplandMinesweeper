import { GameViewModel } from '../viewModel/GameViewModel';
import { CellComponent } from './CellComponent';
import { Cell } from '../model/Cell';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct GameBoard {
  @ObjectLink viewModel: GameViewModel;
  @ObjectLink provider: ThemeProvider;

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
                onFlag: (x: number, y: number): void => this.viewModel.flagCell(x, y)
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
    });
  }
}
