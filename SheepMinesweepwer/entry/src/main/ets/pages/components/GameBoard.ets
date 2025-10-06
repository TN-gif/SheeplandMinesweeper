import { GameViewModel } from '../viewModel/GameViewModel';
import { CellComponent } from './CellComponent';
import { Cell } from '../model/Cell';

@Component
export struct GameBoard {
  @ObjectLink viewModel: GameViewModel;

  build() {
    Grid() {
      ForEach(this.viewModel.board, (row: Cell[]) => {
        ForEach(row, (cell: Cell) => {
          GridItem() {
            CellComponent({
              cell: cell,
              onReveal: (x: number, y: number): void => this.viewModel.revealCell(x, y),
              onFlag: (x: number, y: number): void => this.viewModel.flagCell(x, y)
            });
          }
        });
      });
    }
    .columnsTemplate('1fr '.repeat(this.viewModel.cols))
    .rowsTemplate('1fr '.repeat(this.viewModel.rows))
    .width('100%')
    .aspectRatio(1);
  }
}
