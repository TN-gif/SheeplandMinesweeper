import { Cell } from '../model/Cell';

@Component
export struct CellComponent {
  @ObjectLink cell: Cell;
  onReveal: (x: number, y: number) => void = () => {};
  onFlag: (x: number, y: number) => void = () => {};

  build() {
    Button() {
      if (this.cell.isRevealed) {
        if (this.cell.isMine) {
          Text('💣').fontSize(20);
        } else if (this.cell.adjacentMines > 0) {
          Text(this.cell.adjacentMines.toString())
            .fontSize(20)
            .fontColor(this.getNumberColor(this.cell.adjacentMines));
        }
      } else if (this.cell.isFlagged) {
        Text('🚩').fontSize(20);
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.cell.isRevealed ? '#d3e8d3' : '#a0c8a0')
    .border({ width: 1, color: '#80a880' })
    .onClick(() => {
      this.onReveal(this.cell.x, this.cell.y);
    })
    .gesture(
      LongPressGesture({})
        .onAction(() => {
          this.onFlag(this.cell.x, this.cell.y);
        })
    )
    .animation({ duration: 300, curve: Curve.EaseInOut })
    .rotate({ x: 0, y: this.cell.isRevealed ? 1 : 0, z: 0, angle: this.cell.isRevealed ? 180 : 0 })
    .scale({ x: this.cell.isRevealed ? 0.95 : 1, y: this.cell.isRevealed ? 0.95 : 1 })
    .translate({ x: this.cell.shake ? 5 : 0 })
    .animation(this.cell.shake ? { duration: 100, curve: Curve.EaseInOut, iterations: 4, playMode: PlayMode.Normal } : { duration: 0 });
  }

  getNumberColor(mines: number): Color {
    switch (mines) {
      case 1: return Color.Blue;
      case 2: return Color.Green;
      case 3: return Color.Red;
      case 4: return Color.Purple;
      case 5: return Color.Brown;
      case 6: return Color.Orange;
      default: return Color.Black;
    }
  }
}
