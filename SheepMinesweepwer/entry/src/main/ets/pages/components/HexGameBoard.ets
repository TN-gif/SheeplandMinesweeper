import { HexGameViewModel } from '../viewModel/HexGameViewModel';
import { HexUtils, AxialCoord, HexCell, Point } from '../model/HexUtils';
import { themeProvider } from '../theme/ThemeProvider';
import { audioManager } from '../services/AudioManager';

class CanvasSize {
  width: number = 0;
  height: number = 0;
}

@Component
export struct HexGameBoard {
  @ObjectLink viewModel: HexGameViewModel;
  private canvasContext: CanvasRenderingContext2D | null = null;
  private canvasSize: CanvasSize = new CanvasSize();
  private hexSize: number = 30; // Radius of a hexagon in pixels
  private origin: Point = new Point(0, 0);
  private longPressTimer: number = -1;
  private longPressCoord: AxialCoord | null = null;
  @State needsRedraw: number = 0; // 用于触发重绘

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
      this.drawHex(ctx, center, cell);
      this.drawHexContent(ctx, center, cell);
    });
  }

  private drawHex(ctx: CanvasRenderingContext2D, center: Point, cell: HexCell): void {
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
    
    // 根据状态设置颜色
    if (cell.isRevealed) {
      if (cell.isMine) {
        ctx.fillStyle = '#FFE4E1'; // 地雷时的红色背景
      } else if (cell.adjacentMines > 0) {
        ctx.fillStyle = '#F5F5DC'; // 有数字时的浅黄色背景
      } else {
        ctx.fillStyle = '#B9D8A5'; // 翻开无数字时的草地色
      }
    } else {
      ctx.fillStyle = '#D2B48C'; // 未翻开时的土地色
    }
    ctx.fill();
    
    ctx.strokeStyle = cell.isRevealed ? '#98B888' : '#A0856C';
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  private drawHexContent(ctx: CanvasRenderingContext2D, center: Point, cell: HexCell): void {
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';

    if (cell.isFlagged) {
      ctx.font = 'bold 20px sans-serif';
      ctx.fillText('⚑', center.x, center.y);
    } else if (cell.isRevealed) {
      if (cell.isMine) {
        ctx.font = '20px sans-serif';
        ctx.fillText('🐺', center.x, center.y);
      } else if (cell.adjacentMines > 0) {
        ctx.font = 'bold 20px sans-serif';
        const colors: string[] = ['', '#67AA53', '#41A9CE', '#FF4444', '#9C27B0', '#FF6F00', '#00BCD4'];
        ctx.fillStyle = colors[Math.min(cell.adjacentMines, colors.length - 1)];
        ctx.fillText(cell.adjacentMines.toString(), center.x, center.y);
      }
    }
  }

  private handleTouchStart(event: TouchEvent): void {
    if (!event || !event.touches || event.touches.length === 0) return;
    
    const touch: TouchObject = event.touches[0];
    const touchX: number = touch.x;
    const touchY: number = touch.y;
    const tappedHex: AxialCoord = HexUtils.pixelToAxial(touchX, touchY, this.hexSize, this.origin);
    
    // 保存坐标用于长按
    this.longPressCoord = tappedHex;
    
    // 启动长按定时器（500ms触发插旗）
    this.longPressTimer = setTimeout(() => {
      if (this.longPressCoord) {
        this.viewModel.flagCell(this.longPressCoord.q, this.longPressCoord.r);
        audioManager.playSound('flag');
        this.draw();
        this.needsRedraw++; // 触发状态更新
      }
    }, 500);
  }

  private handleTouchEnd(event: TouchEvent): void {
    // 清除长按定时器
    if (this.longPressTimer >= 0) {
      clearTimeout(this.longPressTimer);
      this.longPressTimer = -1;
    }
    
    // 如果坐标存在且定时器刚被清除，说明是短按（翻开）
    if (this.longPressCoord && event.touches.length === 0) {
      this.viewModel.revealCell(this.longPressCoord.q, this.longPressCoord.r);
      audioManager.playSound('click');
      this.draw();
      this.needsRedraw++;
      this.longPressCoord = null;
    }
  }

  private handleTouchCancel(): void {
    // 清除长按定时器
    if (this.longPressTimer >= 0) {
      clearTimeout(this.longPressTimer);
      this.longPressTimer = -1;
    }
    this.longPressCoord = null;
  }

  build() {
    Canvas(this.canvasContext)
      .width('100%')
      .height('100%')
      .onReady(() => {
        this.onReady();
      })
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          this.handleTouchStart(event);
        } else if (event.type === TouchType.Up) {
          this.handleTouchEnd(event);
        } else if (event.type === TouchType.Cancel) {
          this.handleTouchCancel();
        }
      })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        if (newValue && newValue.width && newValue.height) {
          this.canvasSize.width = newValue.width as number;
          this.canvasSize.height = newValue.height as number;
          this.origin = new Point(this.canvasSize.width / 2, this.canvasSize.height / 2);
          this.draw();
        }
      });
  }
}
