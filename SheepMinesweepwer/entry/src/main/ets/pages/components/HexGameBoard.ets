import { HexGameViewModel } from '../viewModel/HexGameViewModel';
import { HexUtils, AxialCoord, HexCell } from '../model/HexUtils';
import { CanvasRenderingContext2D } from '@ohos.graphics.CanvasRenderingContext2D';
import { TouchEvent, TouchType } from '@ohos.multimodalInput.touchEvent';

@Component
export struct HexGameBoard {
  @ObjectLink viewModel: HexGameViewModel;
  private canvasContext: CanvasRenderingContext2D | null = null;
  private canvasSize: { width: number, height: number } = { width: 0, height: 0 };
  private hexSize: number = 25; // Radius of a hexagon in pixels
  private origin: { x: number, y: number } = { x: 0, y: 0 };

  private onReady() {
    this.draw();
  }

  private draw() {
    if (!this.canvasContext) return;
    const ctx = this.canvasContext;
    ctx.clearRect(0, 0, this.canvasSize.width, this.canvasSize.height);

    this.viewModel.board.forEach(cell => {
      const center = HexUtils.axialToPixel({ q: cell.q, r: cell.r }, this.hexSize, this.origin);
      this.drawHex(ctx, center);
      this.drawHexContent(ctx, center, cell);
    });
  }

  private drawHex(ctx: CanvasRenderingContext2D, center: { x: number, y: number }) {
    ctx.beginPath();
    for (let i = 0; i < 6; i++) {
      const angle = (Math.PI / 180) * (60 * i);
      const x = center.x + this.hexSize * Math.cos(angle);
      const y = center.y + this.hexSize * Math.sin(angle);
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

  private drawHexContent(ctx: CanvasRenderingContext2D, center: { x: number, y: number }, cell: HexCell) {
    ctx.fillStyle = 'black';
    ctx.font = '16px sans-serif';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    if (cell.isFlagged) {
      ctx.fillText('덫', center.x, center.y);
    } else if (cell.isRevealed) {
      if (cell.isMine) {
        ctx.fillText('🐺', center.x, center.y);
      } else if (cell.adjacentMines > 0) {
        ctx.fillText(cell.adjacentMines.toString(), center.x, center.y);
      }
    }
  }

  private handleTouch(event: TouchEvent) {
    if (event.type === TouchType.Down) {
      const touchX = event.touches[0].x;
      const touchY = event.touches[0].y;
      const tappedHex = HexUtils.pixelToAxial(touchX, touchY, this.hexSize, this.origin);
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
      .onAreaChange((oldValue, newValue) => {
        this.canvasSize.width = newValue.width as number;
        this.canvasSize.height = newValue.height as number;
        this.origin = { x: this.canvasSize.width / 2, y: this.canvasSize.height / 2 };
        this.draw();
      });
  }
}
