import { Level } from '../model/Level';
import { BusinessError } from '@ohos.base';
import { getContext } from '@ohos.abilityAccessCtrl';

@Component
export struct LevelSelectScreen {
  @State levels: Level[] = [];
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};

  async aboutToAppear(): Promise<void> {
    try {
      const context = getContext(this);
      const rawFile = await context.resourceManager.getRawFileContent('levels.json');
      let jsonString = '';
      for (let i = 0; i < rawFile.length; i++) {
        jsonString += String.fromCharCode(rawFile[i]);
      }
      this.levels = JSON.parse(jsonString) as Level[];
    } catch (e) {
      const error = e as BusinessError;
      console.error(`Failed to load levels: ${error.message}, code: ${error.code}`);
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
            Button(level.name)
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
