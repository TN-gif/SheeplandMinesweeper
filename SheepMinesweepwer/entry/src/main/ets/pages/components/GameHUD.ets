import { GameViewModel } from '../viewModel/GameViewModel';
import { itemService } from '../services/ItemService';
import { Item } from '../model/Item';

@Component
export struct GameHUD {
  @ObjectLink viewModel: GameViewModel;
  @State inventory: Item[] = [];
  private timerId: number = -1;

  aboutToAppear() {
    this.inventory = itemService.getInventory();
    // ... (timer logic is the same)
  }

  // ... (aboutToDisappear is the same)

  build() {
    Column() {
      // Top section with stats
      Row() {
        // ... (Wolf and Timer text)
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#4CAF50');

      // Bottom section with item bar
      Row({ space: 15 }) {
        ForEach(this.inventory || [], (item: Item) => {
          if (item) {
            Button() {
              Text(`${item.name} x${item.quantity}`)
                .fontSize(16);
            }
            .onClick(() => {
              this.viewModel.selectItem(item.id);
            })
            .backgroundColor(this.viewModel.selectedItem === item.id ? '#FFD700' : '#FFFFFF')
            .fontColor(Color.Black)
            .enabled(item.quantity > 0);
          }
        });
      }
      .width('100%')
      .padding(10)
      .backgroundColor('#f0f0f0');
    }
  }
}
