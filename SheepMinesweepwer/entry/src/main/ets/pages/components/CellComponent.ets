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

  getNumberColor(mines: number): string {
    switch (mines) {
      case 1: return '#0000FF'; // 蓝色
      case 2: return '#008000'; // 绿色
      case 3: return '#FF0000'; // 红色
      case 4: return '#800080'; // 紫色
      case 5: return '#8B4513'; // 棕色
      case 6: return '#FFA500'; // 橙色
      default: return '#000000'; // 黑色
    }
  }
}
