import { Level } from '../model/Level';
import { BusinessError } from '@ohos.base';
import common from '@ohos.app.ability.common';
import { ThemeProvider, themeProvider } from '../theme/ThemeProvider';
import util from '@ohos.util';

@Component
export struct LevelSelectScreen {
  @State levels: Level[] = [];
  @ObjectLink provider: ThemeProvider;
  onSelectLevel: (level: Level) => void = () => {};
  onBack: () => void = () => {};
  context?: common.UIAbilityContext;
  
  // 自定义关卡参数
  @State showCustomDialog: boolean = false;
  @State customRows: string = '10';
  @State customCols: string = '10';
  @State customMines: string = '15';

  async aboutToAppear(): Promise<void> {
    if (!this.context) {
      console.error('Context is not provided to LevelSelectScreen');
      return;
    }
    try {
      const rawFile: Uint8Array = await this.context.resourceManager.getRawFileContent('levels.json');
      // 使用UTF-8解码器正确解析中文（使用新的API）
      const textDecoder = util.TextDecoder.create('utf-8');
      const jsonString: string = textDecoder.decodeToString(rawFile);
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

      // 按钮组
      Row({ space: 15 }) {
        // 自定义关卡按钮
        Button('自定义')
          .width('40%')
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.provider.currentTheme.colors.secondary)
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.showCustomDialog = true;
          });

        // 返回按钮
        Button('返回菜单')
          .width('40%')
          .height(55)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF9800')
          .borderRadius(15)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(this.onBack);
      }
      .width('85%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20, bottom: 30 });
    }
    .width('100%')
    .height('100%')
    .backgroundImage(this.provider.currentTheme.assets.background)
    .backgroundImageSize(ImageSize.Cover)
    .bindContentCover(this.showCustomDialog, this.CustomLevelDialog(), {
      modalTransition: ModalTransition.DEFAULT
    });
  }

  @Builder CustomLevelDialog() {
    Column({ space: 20 }) {
      Text('自定义关卡')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.provider.currentTheme.colors.textPrimary)
        .margin({ top: 30 });

      // 行数输入
      Column({ space: 8 }) {
        Text('棋盘行数 (5-30)')
          .fontSize(18)
          .fontColor(this.provider.currentTheme.colors.textPrimary);
        TextInput({ text: this.customRows })
          .type(InputType.Number)
          .fontSize(18)
          .onChange((value: string) => {
            this.customRows = value;
          })
          .width('100%')
          .height(50)
          .backgroundColor(this.provider.currentTheme.colors.cardBg)
          .borderRadius(10);
      }
      .alignItems(HorizontalAlign.Start)
      .width('85%');

      // 列数输入
      Column({ space: 8 }) {
        Text('棋盘列数 (5-30)')
          .fontSize(18)
          .fontColor(this.provider.currentTheme.colors.textPrimary);
        TextInput({ text: this.customCols })
          .type(InputType.Number)
          .fontSize(18)
          .onChange((value: string) => {
            this.customCols = value;
          })
          .width('100%')
          .height(50)
          .backgroundColor(this.provider.currentTheme.colors.cardBg)
          .borderRadius(10);
      }
      .alignItems(HorizontalAlign.Start)
      .width('85%');

      // 地雷数输入
      Column({ space: 8 }) {
        Text('地雷数量')
          .fontSize(18)
          .fontColor(this.provider.currentTheme.colors.textPrimary);
        TextInput({ text: this.customMines })
          .type(InputType.Number)
          .fontSize(18)
          .onChange((value: string) => {
            this.customMines = value;
          })
          .width('100%')
          .height(50)
          .backgroundColor(this.provider.currentTheme.colors.cardBg)
          .borderRadius(10);
      }
      .alignItems(HorizontalAlign.Start)
      .width('85%');

      // 按钮组
      Row({ space: 20 }) {
        Button('取消')
          .width('40%')
          .height(50)
          .fontSize(18)
          .backgroundColor('#999999')
          .borderRadius(12)
          .onClick(() => {
            this.showCustomDialog = false;
          });

        Button('开始游戏')
          .width('40%')
          .height(50)
          .fontSize(18)
          .backgroundColor(this.provider.currentTheme.colors.primary)
          .borderRadius(12)
          .onClick(() => {
            const rows = parseInt(this.customRows);
            const cols = parseInt(this.customCols);
            const mines = parseInt(this.customMines);

            // 验证输入
            if (rows >= 5 && rows <= 30 && cols >= 5 && cols <= 30 && mines > 0 && mines < rows * cols) {
              // 使用构造函数创建Level对象，避免对象字面量错误
              const customLevel: Level = new Level(
                'custom',
                '自定义关卡',
                rows,
                cols,
                mines,
                true
              );
              this.showCustomDialog = false;
              this.onSelectLevel(customLevel);
            } else {
              console.error('Invalid custom level parameters');
            }
          });
      }
      .width('85%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 20 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.provider.currentTheme.colors.background)
    .justifyContent(FlexAlign.Start);
  }
}
