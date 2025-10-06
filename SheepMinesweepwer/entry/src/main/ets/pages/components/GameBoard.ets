import { GameViewModel } from '../viewModel/GameViewModel';
import { CellComponent } from './CellComponent';

@Component
export struct GameBoard {
  @ObjectLink viewModel: GameViewModel;

  build() {
    Grid() {
      ForEach(this.viewModel.board, (row) => {
        ForEach(row, (cell) => {
          GridItem() {
            CellComponent({
              cell: cell,
              onReveal: (x, y) => this.viewModel.revealCell(x, y),
              onFlag: (x, y) => this.viewModel.flagCell(x, y)
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
