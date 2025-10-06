
import { Achievement } from '../model/Achievement';
import { achievementService } from '../services/AchievementService';

@Component
export struct AchievementsScreen {
  @State achievements: Achievement[] = [];
  onBack: () => void;

  aboutToAppear() {
    this.achievements = achievementService.getAchievements();
  }

  build() {
    Column() {
      Text('成就殿堂')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .margin(20);

      List({ space: 10 }) {
        ForEach(this.achievements, (ach: Achievement) => {
          ListItem() {
            Row() {
              Text(ach.unlocked ? '🏆' : '🔒')
                .fontSize(30)
                .width(50)
                .textAlign(TextAlign.Center);

              Column({ space: 5 }) {
                Text(ach.name)
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ach.unlocked ? Color.Black : Color.Gray);
                Text(ach.description)
                  .fontSize(16)
                  .fontColor(ach.unlocked ? Color.Gray : Color.Silver);
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);
            }
            .padding(15)
            .backgroundColor(Color.White)
            .borderRadius(10)
            .opacity(ach.unlocked ? 1.0 : 0.6);
          }
        });
      }
      .layoutWeight(1)
      .padding({ left: 10, right: 10 });

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
