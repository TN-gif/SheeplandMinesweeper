import { HexGameViewModel } from './viewModel/HexGameViewModel';
import { HexGameBoard } from './components/HexGameBoard';
import { ThemeProvider, themeProvider } from './theme/ThemeProvider';

@Component
export struct HexGamePage {
  @State viewModel: HexGameViewModel = new HexGameViewModel();
  @ObjectLink provider: ThemeProvider;
  onBack: () => void = () => {};

  build() {
    Column() {
      // 标题
      Text('六边形挑战')
        .fontSize(38)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .margin({ top: 30, bottom: 20 })
        .textShadow({ radius: 3, color: '#00000030', offsetX: 2, offsetY: 2 });

      // 游戏状态
      if (this.viewModel.gameOver) {
        Column() {
          Text(this.viewModel.gameWon ? '🎉' : '💥')
            .fontSize(40);
          Text(this.viewModel.gameWon ? '胜利！' : '失败了！')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.viewModel.gameWon ? '#FFD700' : '#FF6B6B')
            .margin({ top: 10 });
        }
        .width('80%')
        .height(120)
        .backgroundColor(this.viewModel.gameWon ? '#FFFACD' : '#FFE4E1')
        .borderRadius(20)
        .justifyContent(FlexAlign.Center)
        .shadow({ 
          radius: 15, 
          color: this.viewModel.gameWon ? '#FFD70060' : '#FF6B6B60', 
          offsetX: 0, 
          offsetY: 6 
        })
        .margin({ bottom: 20 });
      }

      // 游戏棋盘
      HexGameBoard({ viewModel: this.viewModel })
        .layoutWeight(1)
        .margin({ bottom: 20 });

      // 底部按钮
      Row({ space: 20 }) {
        Button('新游戏')
          .width(150)
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.provider.currentTheme.colors.primary)
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => this.viewModel.initGame());

        Button('返回菜单')
          .width(150)
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF9800')
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => this.onBack());
      }
      .padding({ bottom: 30 });
    }
    .width('100%')
    .height('100%')
    .backgroundImage(this.provider.currentTheme.assets.background)
    .backgroundImageSize(ImageSize.Cover);
  }
}
