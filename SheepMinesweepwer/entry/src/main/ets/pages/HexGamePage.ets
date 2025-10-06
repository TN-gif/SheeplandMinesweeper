import { HexGameViewModel } from '../viewModel/HexGameViewModel';
import { HexGameBoard } from './HexGameBoard';

@Component
export struct HexGamePage {
  @State viewModel: HexGameViewModel = new HexGameViewModel();
  onBack: () => void;

  build() {
    Column() {
      Text('六边形挑战')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .padding(20);

      if (this.viewModel.gameOver) {
        Text(this.viewModel.gameWon ? '胜利！' : '失败了！')
          .fontSize(24)
          .fontColor(this.viewModel.gameWon ? Color.Green : Color.Red)
          .margin(10);
      }

      HexGameBoard({ viewModel: this.viewModel })
        .layoutWeight(1);


      Row({ space: 20 }) {
        Button('新游戏')
          .onClick(() => this.viewModel.initGame())
          .margin(10);
        Button('返回菜单')
          .onClick(() => this.onBack())
          .margin(10);
      }
      .padding(10);
    }
    .width('100%')
    .height('100%');
  }
}
