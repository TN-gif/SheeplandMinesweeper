import { Cell } from '../model/Cell';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct CellComponent {
  @ObjectLink cell: Cell;
  @ObjectLink provider: ThemeProvider;
  onReveal: (x: number, y: number) => void = () => {};
  onFlag: (x: number, y: number) => void = () => {};

  build() {
    Stack() {
      // 背景层
      Image(this.cell.isRevealed ? 
        this.provider.currentTheme.assets.grassIcon : 
        this.provider.currentTheme.assets.landIcon)
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(4)
        .onError(() => {
          console.error('Failed to load cell background image');
        });

      // 内容层
      if (this.cell.isRevealed) {
        if (this.cell.isMine) {
          // 灰太狼图标
          Image(this.provider.currentTheme.assets.mineIcon)
            .width('70%')
            .height('70%')
            .objectFit(ImageFit.Contain)
            .onError(() => {
              console.error('Failed to load mine icon');
            });
        } else if (this.cell.adjacentMines > 0) {
          // 数字显示
          Text(this.cell.adjacentMines.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getNumberColor(this.cell.adjacentMines))
            .textShadow({ radius: 2, color: '#FFFFFF80', offsetX: 0, offsetY: 0 });
        }
      } else if (this.cell.isFlagged) {
        // 捕狼夹图标
        Image(this.provider.currentTheme.assets.flagIcon)
          .width('60%')
          .height('60%')
          .objectFit(ImageFit.Contain)
          .onError(() => {
            console.error('Failed to load flag icon');
          });
      }
    }
    .width('100%')
    .height('100%')
    .border({ 
      width: 2, 
      color: this.cell.isRevealed ? this.provider.currentTheme.colors.primary + '40' : '#FFFFFF80'
    })
    .borderRadius(6)
    .shadow({
      radius: this.cell.isRevealed ? 2 : 6,
      color: '#00000020',
      offsetX: 0,
      offsetY: this.cell.isRevealed ? 1 : 3
    })
    .onClick(() => {
      if (!this.cell.isRevealed) {
        this.onReveal(this.cell.x, this.cell.y);
      }
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          if (!this.cell.isRevealed) {
            this.onFlag(this.cell.x, this.cell.y);
          }
        })
    )
    .scale({ 
      x: this.cell.isRevealed ? 0.95 : (this.cell.isFlagged ? 1.05 : 1), 
      y: this.cell.isRevealed ? 0.95 : (this.cell.isFlagged ? 1.05 : 1)
    })
    .rotate({ 
      x: 1, 
      y: 0, 
      z: 0, 
      angle: this.cell.isRevealed ? 10 : 0,
      centerX: '50%',
      centerY: '50%'
    })
    .translate({ 
      x: this.cell.shake ? (Math.random() > 0.5 ? 5 : -5) : 0,
      y: this.cell.shake ? (Math.random() > 0.5 ? 5 : -5) : 0
    })
    .animation({ 
      duration: 300, 
      curve: Curve.EaseInOut,
      iterations: this.cell.shake ? 5 : 1
    })
    .opacity(this.cell.isRevealed ? 0.9 : 1);
  }

  getNumberColor(mines: number): string {
    const theme = this.provider.currentTheme;
    switch (mines) {
      case 1: return theme.colors.primary;       // 主题色
      case 2: return theme.colors.secondary;     // 次要色
      case 3: return '#FF4444';                  // 红色
      case 4: return '#9C27B0';                  // 紫色
      case 5: return '#FF6F00';                  // 橙色
      case 6: return '#00BCD4';                  // 青色
      case 7: return '#795548';                  // 棕色
      case 8: return '#424242';                  // 深灰
      default: return theme.colors.textPrimary;
    }
  }
}
