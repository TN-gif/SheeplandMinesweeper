import { Level } from '../model/Level';
import resourceManager from '@ohos.resourceManager';

@Component
export struct LevelSelectScreen {
  @State levels: Level[] = [];
  onSelectLevel: (level: Level) => void;
  onBack: () => void; // To go back to the main menu

  async aboutToAppear() {
    try {
      const rawFile = await resourceManager.getRawFileContent('levels.json');
      const jsonString = String.fromCharCode(...new Uint8Array(rawFile.buffer));
      this.levels = JSON.parse(jsonString);
    } catch (error) {
      console.error('Failed to load levels:', error);
    }
  }

  build() {
    Column() {
      Text('Challenge Mode')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin(20);

      List({ space: 10 }) {
        ForEach(this.levels, (level: Level) => {
          ListItem() {
            Button(level.levelName)
              .width('100%')
              .fontSize(20)
              .padding(15)
              .backgroundColor('#4CAF50')
              .fontColor(Color.White)
              .onClick(() => {
                this.onSelectLevel(level);
              });
          }
        });
      }
      .layoutWeight(1)
      .padding({ left: 10, right: 10 });

      Button('Back')
        .onClick(this.onBack)
        .margin(20)
        .fontSize(18);
    }
    .width('100%')
    .height('100%');
  }
}
