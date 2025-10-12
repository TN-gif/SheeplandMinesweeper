import { Cell } from '../model/Cell';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct CellComponent {
  @ObjectLink cell: Cell;
  @ObjectLink provider: ThemeProvider;
  onReveal: (x: number, y: number) => void = () => {};
  onFlag: (x: number, y: number) => void = () => {};
  onChord: (x: number, y: number) => void = () => {};

  build() {
    Stack() {
      // 背景层 - 只有在未翻开或翻开且无数字时才显示图片
      if (!this.cell.isRevealed) {
        // 未翻开时显示土地
        Image(this.provider.currentTheme.assets.landIcon)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(4)
          .draggable(false)  // 关闭拖拽，避免阻止长按手势
          .onError(() => {
            console.error('Failed to load cell background image');
          });
      } else if (this.cell.isRevealed && this.cell.adjacentMines === 0 && !this.cell.isMine) {
        // 翻开且无数字时显示草地
        Image(this.provider.currentTheme.assets.grassIcon)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(4)
          .draggable(false)  // 关闭拖拽，避免阻止长按手势
          .onError(() => {
            console.error('Failed to load cell background image');
          });
      } else if (this.cell.isRevealed && this.cell.adjacentMines > 0) {
        // 有数字时显示纯色背景
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#F5F5DC')
          .borderRadius(4);
      } else if (this.cell.isRevealed && this.cell.isMine) {
        // 地雷时显示草地背景
        Image(this.provider.currentTheme.assets.grassIcon)
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
          .borderRadius(4)
          .draggable(false)  // 关闭拖拽，避免阻止长按手势
          .onError(() => {
            console.error('Failed to load cell background image');
          });
      }

      // 内容层
      if (this.cell.isRevealed) {
        if (this.cell.isMine) {
          // 灰太狼图标
          Image(this.provider.currentTheme.assets.mineIcon)
            .width('70%')
            .height('70%')
            .objectFit(ImageFit.Contain)
            .draggable(false)  // 关闭拖拽，避免阻止长按手势
            .onError(() => {
              console.error('Failed to load mine icon');
            });
        } else if (this.cell.adjacentMines > 0) {
          // 数字显示（在纯色背景上更清晰）
          Text(this.cell.adjacentMines.toString())
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.getNumberColor(this.cell.adjacentMines))
            .textShadow({ radius: 1, color: '#FFFFFF', offsetX: 1, offsetY: 1 });
        }
      } else if (this.cell.isFlagged) {
        // 捕狼夹图标
        Image(this.provider.currentTheme.assets.flagIcon)
          .width('60%')
          .height('60%')
          .objectFit(ImageFit.Contain)
          .draggable(false)  // 关闭拖拽，避免阻止长按手势
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
    .gesture(
      GestureGroup(GestureMode.Exclusive,
        // 双击手势：用于和弦操作（优先级最高）
        TapGesture({ count: 2 })
          .onAction(() => {
            if (this.cell.isRevealed && this.cell.adjacentMines > 0) {
              this.onChord(this.cell.x, this.cell.y);
            }
          }),
        // 长按手势：用于插旗（优先级次之）
        LongPressGesture({ repeat: false, duration: 500 })
          .onAction(() => {
            if (!this.cell.isRevealed) {
              this.onFlag(this.cell.x, this.cell.y);
            }
          }),
        // 单击手势：用于翻开（优先级最低）
        TapGesture({ count: 1 })
          .onAction(() => {
            if (!this.cell.isRevealed) {
              this.onReveal(this.cell.x, this.cell.y);
            }
          })
      )
    )
    .scale({ 
      x: this.cell.isRevealed ? 0.98 : (this.cell.isFlagged ? 1.03 : 1), 
      y: this.cell.isRevealed ? 0.98 : (this.cell.isFlagged ? 1.03 : 1)
    })
    .animation({ 
      duration: 250, 
      curve: Curve.EaseInOut
    })
    .opacity(this.cell.isRevealed ? 1 : 1);
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
