import { Level } from '../model/Level';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';

@Component
export struct LevelSelectScreen {
  @State levels: Level[] = [];
  @ObjectLink provider: ThemeProvider;
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};
  context?: common.UIAbilityContext;

  async aboutToAppear(): Promise<void> {
    if (!this.context) {
      console.error('Context is not provided to LevelSelectScreen');
      return;
    }
    try {
      const rawFile: Uint8Array = await this.context.resourceManager.getRawFileContent('levels.json');
      let jsonString: string = '';
      for (let i: number = 0; i < rawFile.length; i++) {
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
      // 标题
      Text('挑战模式')
        .fontSize(40)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .margin({ top: 40, bottom: 30 })
        .textShadow({ radius: 3, color: '#00000030', offsetX: 2, offsetY: 2 });

      // 关卡列表
      List({ space: 15 }) {
        ForEach(this.levels || [], (level: Level, index: number) => {
          if (level) {
            ListItem() {
              Row() {
                // 关卡编号
                Text(`${index + 1}`)
                  .fontSize(28)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(this.provider.currentTheme.colors.primary)
                  .width(60)
                  .textAlign(TextAlign.Center);

                // 关卡信息
                Column({ space: 5 }) {
                  Text(level.name)
                    .fontSize(22)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.provider.currentTheme.colors.textPrimary);
                  Text(`${level.rows}×${level.cols} | ${level.mines} 个灰太狼`)
                    .fontSize(16)
                    .fontColor(this.provider.currentTheme.colors.textSecondary);
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);

                // 箭头图标
                Text('▶')
                  .fontSize(20)
                  .fontColor(this.provider.currentTheme.colors.primary);
              }
              .width('90%')
              .height(80)
              .padding({ left: 15, right: 15 })
              .backgroundColor(this.provider.currentTheme.colors.cardBg)
              .borderRadius(15)
              .shadow({ radius: 8, color: '#00000020', offsetX: 0, offsetY: 4 })
              .onClick(() => {
                this.onSelectLevel(level);
              });
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
