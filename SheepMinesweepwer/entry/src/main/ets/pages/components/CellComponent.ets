import { Cell } from '../model/Cell';

@Component
export struct CellComponent {
  @ObjectLink cell: Cell;
  onReveal: (x: number, y: number) => void;
  onFlag: (x: number, y: number) => void;

  build() {
    Button() {
      // ... (The content of the button is the same)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.cell.isRevealed ? '#d3e8d3' : '#a0c8a0')
    .border({ width: 1, color: '#80a880' })
    .onClick(() => {
      this.onReveal(this.cell.x, this.cell.y);
    })
    .onLongPress(() => {
      this.onFlag(this.cell.x, this.cell.y);
    })
    .animation({ duration: 300, curve: Curve.EaseInOut })
    .rotate({ x: 0, y: this.cell.isRevealed ? 1 : 0, z: 0, angle: this.cell.isRevealed ? 180 : 0 })
    .scale({ x: this.cell.isRevealed ? 0.95 : 1, y: this.cell.isRevealed ? 0.95 : 1 })
    .translate({ x: this.cell.shake ? 5 : 0 })
    .animation(this.cell.shake ? { duration: 100, curve: Curve.EaseInOut, iterations: 4, playMode: PlayMode.Normal } : { duration: 0 });
  }

  // ... (getNumberColor is the same)
}
