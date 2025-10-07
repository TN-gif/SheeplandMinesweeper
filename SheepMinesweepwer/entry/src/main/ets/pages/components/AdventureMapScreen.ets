import { adventureService } from '../services/AdventureService';
import { Level } from '../model/Level';
import { AdventureStage } from '../services/AdventureService';
import common from '@ohos.app.ability.common';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct AdventureMapScreen {
  @State stages: AdventureStage[] = [];
  @State currentStageIndex: number = 0;
  @ObjectLink provider: ThemeProvider;
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};
  context?: common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    // 服务已在主页面初始化，这里只需获取数据
    this.stages = adventureService.getStages();
    this.currentStageIndex = adventureService.getCurrentStageIndex();
  }

  build() {
    Column() {
      // 标题
      Text('🗺️ 冒险之旅 🗺️')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .margin({ top: 40, bottom: 30 })
        .textShadow({ radius: 3, color: '#00000030', offsetX: 2, offsetY: 2 });

      // 关卡列表
      List({ space: 20 }) {
        ForEach(this.stages || [], (stage: AdventureStage, index: number) => {
          if (stage) {
          ListItem() {
            Column({ space: 12 }) {
              // 关卡标题行
              Row() {
                Text(`第 ${index + 1} 关`)
                  .fontSize(26)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(index <= this.currentStageIndex ? 
                    this.provider.currentTheme.colors.primary : 
                    '#A0A0A0');
                
                Blank();

                // 状态图标
                if (index < this.currentStageIndex) {
                  Text('✓')
                    .fontSize(28)
                    .fontColor(this.provider.currentTheme.colors.accent)
                    .fontWeight(FontWeight.Bold);
                } else if (index === this.currentStageIndex) {
                  Text('▶')
                    .fontSize(24)
                    .fontColor(this.provider.currentTheme.colors.primary);
                } else {
                  Text('🔒')
                    .fontSize(24);
                }
              }
              .width('100%');

              // 关卡描述
              Text(stage.introText)
                .fontSize(18)
                .fontColor(index <= this.currentStageIndex ? 
                  this.provider.currentTheme.colors.textSecondary : 
                  '#C0C0C0')
                .textAlign(TextAlign.Start);

              // 开始按钮
              Button(index < this.currentStageIndex ? '重新挑战' : '开始挑战')
                .width('100%')
                .height(50)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .backgroundColor(index === this.currentStageIndex ? 
                  this.provider.currentTheme.colors.primary : 
                  (index < this.currentStageIndex ? 
                    this.provider.currentTheme.colors.secondary : 
                    '#D0D0D0'))
                .borderRadius(12)
                .enabled(index <= this.currentStageIndex)
                .onClick(() => {
                  const level = adventureService.getLevelForStage(stage);
                  if (level) {
                    this.onSelectLevel(level);
                  }
                });
            }
            .width('90%')
            .padding(25)
            .backgroundColor(index <= this.currentStageIndex ? 
              this.provider.currentTheme.colors.cardBg : 
              '#F5F5F5')
            .borderRadius(20)
            .shadow({ 
              radius: index <= this.currentStageIndex ? 12 : 5, 
              color: '#00000030', 
              offsetX: 0, 
              offsetY: index <= this.currentStageIndex ? 6 : 2 
            })
            .opacity(index <= this.currentStageIndex ? 1.0 : 0.6);
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
