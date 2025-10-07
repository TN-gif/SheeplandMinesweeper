import { HexGameViewModel } from '../viewModel/HexGameViewModel';
import { HexUtils, AxialCoord, HexCell, Point } from '../model/HexUtils';

class CanvasSize {
  width: number = 0;
  height: number = 0;
}

@Component
export struct HexGameBoard {
  @ObjectLink viewModel: HexGameViewModel;
  private canvasContext: CanvasRenderingContext2D | null = null;
  private canvasSize: CanvasSize = new CanvasSize();
  private hexSize: number = 25; // Radius of a hexagon in pixels
  private origin: Point = new Point(0, 0);

  private onReady() {
    this.draw();
  }

  private draw(): void {
    if (!this.canvasContext) return;
    const ctx: CanvasRenderingContext2D = this.canvasContext;
    ctx.clearRect(0, 0, this.canvasSize.width, this.canvasSize.height);

    this.viewModel.board.forEach((cell: HexCell) => {
      const cellCoord: AxialCoord = new AxialCoord(cell.q, cell.r);
      const center: Point = HexUtils.axialToPixel(cellCoord, this.hexSize, this.origin);
      this.drawHex(ctx, center);
      this.drawHexContent(ctx, center, cell);
    });
  }

  private drawHex(ctx: CanvasRenderingContext2D, center: Point): void {
    ctx.beginPath();
    for (let i: number = 0; i < 6; i++) {
      const angle: number = (Math.PI / 180) * (60 * i);
      const x: number = center.x + this.hexSize * Math.cos(angle);
      const y: number = center.y + this.hexSize * Math.sin(angle);
      if (i === 0) {
        ctx.moveTo(x, y);
      } else {
        ctx.lineTo(x, y);
      }
    }
    ctx.closePath();
    ctx.fillStyle = '#d3e8d3'; // Prairie color
    ctx.fill();
    ctx.strokeStyle = '#80a880';
    ctx.stroke();
  }

  private drawHexContent(ctx: CanvasRenderingContext2D, center: Point, cell: HexCell): void {
    ctx.fillStyle = 'black';
    ctx.font = '16px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    if (cell.isFlagged) {
      ctx.fillText('🚩', center.x, center.y);
    } else if (cell.isRevealed) {
      if (cell.isMine) {
        ctx.fillText('🐺', center.x, center.y);
      } else if (cell.adjacentMines > 0) {
        ctx.fillText(cell.adjacentMines.toString(), center.x, center.y);
      }
    }
  }

  private handleTouch(event: TouchEvent): void {
    const touches: TouchObject[] = event.touches;
    if (touches.length > 0) {
      const touchX: number = touches[0].x;
      const touchY: number = touches[0].y;
      const tappedHex: AxialCoord = HexUtils.pixelToAxial(touchX, touchY, this.hexSize, this.origin);
      this.viewModel.revealCell(tappedHex.q, tappedHex.r);
      this.draw(); // Redraw after any action
    }
  }

  build() {
    Canvas(this.canvasContext)
      .width('100%')
      .height('100%')
      .onReady(() => this.onReady())
      .onTouch((event: TouchEvent) => this.handleTouch(event))
      .onAreaChange((oldValue: Area, newValue: Area) => {
        this.canvasSize.width = newValue.width as number;
        this.canvasSize.height = newValue.height as number;
        this.origin = new Point(this.canvasSize.width / 2, this.canvasSize.height / 2);
        this.draw();
      });
  }
}
