import { adventureService } from '../services/AdventureService';
import { Level } from '../model/Level';
import { AdventureStage } from '../services/AdventureService';

@Component
export struct AdventureMapScreen {
  @State stages: AdventureStage[] = [];
  @State currentStageIndex: number = 0;
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};

  async aboutToAppear() {
    await adventureService.init();
    this.stages = adventureService.getStages();
    this.currentStageIndex = adventureService.getCurrentStageIndex();
  }

  build() {
    Column() {
      Text('冒险模式')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin(20);

      List({ space: 15 }) {
        ForEach(this.stages, (stage: AdventureStage, index: number) => {
          ListItem() {
            Column() {
              Text(`第 ${index + 1} 关`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor(index <= this.currentStageIndex ? Color.Black : Color.Gray);

              Text(stage.introText)
                .fontSize(16)
                .margin({ top: 5 })
                .fontColor(index <= this.currentStageIndex ? Color.Gray : Color.Silver);

              Button('开始挑战')
                .onClick(() => {
                  const level = adventureService.getLevelForStage(stage);
                  if (level) {
                    this.onSelectLevel(level);
                  }
                })
                .enabled(index === this.currentStageIndex) // Only the current stage is playable
                .margin({ top: 10 });
            }
            .padding(20)
            .backgroundColor(Color.White)
            .borderRadius(15)
            .opacity(index <= this.currentStageIndex ? 1.0 : 0.5);
          }
        });
      }
      .layoutWeight(1)
      .padding({ left: 15, right: 15 });


      Button('返回')
        .onClick(this.onBack)
        .margin(20)
        .fontSize(18);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f8f0');
  }
}
