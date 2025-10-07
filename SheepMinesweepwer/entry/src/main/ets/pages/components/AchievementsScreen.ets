import { Achievement } from '../model/Achievement';
import { achievementService } from '../services/AchievementService';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct AchievementsScreen {
  @State achievements: Achievement[] = [];
  @ObjectLink provider: ThemeProvider;
  onBack: () => void = () => {};

  aboutToAppear() {
    this.achievements = achievementService.getAchievements();
  }

  build() {
    Column() {
      // 标题
      Text('🏆 成就殿堂 🏆')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .margin({ top: 40, bottom: 30 })
        .textShadow({ radius: 3, color: '#00000030', offsetX: 2, offsetY: 2 });

      // 成就列表
      List({ space: 15 }) {
        ForEach(this.achievements || [], (ach: Achievement) => {
          if (ach) {
          ListItem() {
            Row() {
              // 成就图标
              Text(ach.unlocked ? '🏆' : '🔒')
                .fontSize(40)
                .width(70)
                .textAlign(TextAlign.Center);

              // 成就信息
              Column({ space: 8 }) {
                Text(ach.name)
                  .fontSize(22)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(ach.unlocked ? 
                    this.provider.currentTheme.colors.textPrimary : 
                    '#A0A0A0');
                Text(ach.description)
                  .fontSize(17)
                  .fontColor(ach.unlocked ? 
                    this.provider.currentTheme.colors.textSecondary : 
                    '#C0C0C0');
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);

              // 进度标记
              if (ach.unlocked) {
                Text('✓')
                  .fontSize(30)
                  .fontColor(this.provider.currentTheme.colors.accent)
                  .fontWeight(FontWeight.Bold);
              }
            }
            .width('90%')
            .padding(20)
            .backgroundColor(ach.unlocked ? 
              this.provider.currentTheme.colors.cardBg : 
              '#F0F0F0')
            .borderRadius(15)
            .shadow({ 
              radius: ach.unlocked ? 10 : 5, 
              color: ach.unlocked ? '#00000030' : '#00000010', 
              offsetX: 0, 
              offsetY: ach.unlocked ? 5 : 2 
            })
            .opacity(ach.unlocked ? 1.0 : 0.7);
          }
          }
        });
      }
      .layoutWeight(1)
      .width('100%')
      .alignListItem(ListItemAlign.Center);

      // 返回按钮
      Button('返回菜单')
        .width('85%')
        .height(55)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#FF9800')
        .borderRadius(15)
        .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
        .margin({ top: 20, bottom: 30 })
        .onClick(this.onBack);
    }
    .width('100%')
    .height('100%')
    .backgroundImage(this.provider.currentTheme.assets.background)
    .backgroundImageSize(ImageSize.Cover);
  }
}
