/**
 * 角色选择界面
 * 让玩家选择喜欢的小羊角色，并切换对应主题
 */
import { ThemeProvider, themeProvider, THEMES, Theme } from '../theme/ThemeProvider';

@Component
export struct CharacterSelectScreen {
  @ObjectLink provider: ThemeProvider;
  onConfirm: (themeId: string) => void = () => {};
  onBack: () => void = () => {};
  @State selectedThemeId: string = 'xiyangyang';

  build() {
    Column() {
      // 标题
      Text('选择你的小羊伙伴')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D5645')
        .margin({ top: 30, bottom: 30 })
        .textShadow({ radius: 2, color: '#00000020', offsetX: 2, offsetY: 2 });

      // 角色选择网格
      Grid() {
        ForEach(THEMES || [], (theme: Theme) => {
          if (theme) {
          GridItem() {
            this.CharacterCard(theme);
          }
          .padding(10)
          }
        });
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .width('90%')
      .height('60%')
      .margin({ bottom: 30 });

      // 确认按钮
      Row({ space: 20 }) {
        Button('返回')
          .width(140)
          .height(50)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#FF9800')
          .borderRadius(25)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.onBack();
          });

        Button('确认选择')
          .width(180)
          .height(50)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .backgroundColor('#67AA53')
          .borderRadius(25)
          .shadow({ radius: 8, color: '#00000030', offsetX: 0, offsetY: 4 })
          .onClick(() => {
            this.provider.setTheme(this.selectedThemeId);
            this.onConfirm(this.selectedThemeId);
          });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundImage('images/background/背景7.jpg')
    .backgroundImageSize(ImageSize.Cover)
    .justifyContent(FlexAlign.Start);
  }

  @Builder
  CharacterCard(theme: Theme) {
    Column() {
      // 角色头像
      Image(theme.assets.avatar)
        .width(80)
        .height(80)
        .borderRadius(40)
        .border({
          width: this.selectedThemeId === theme.id ? 4 : 2,
          color: this.selectedThemeId === theme.id ? theme.colors.primary : '#FFFFFF'
        })
        .shadow({
          radius: this.selectedThemeId === theme.id ? 12 : 6,
          color: this.selectedThemeId === theme.id ? theme.colors.primary + '60' : '#00000020',
          offsetX: 0,
          offsetY: 4
        })
        .margin({ bottom: 10 })
        .onError(() => {
          console.error('Failed to load character avatar');
        });

      // 角色名称
      Text(theme.name)
        .fontSize(18)
        .fontWeight(this.selectedThemeId === theme.id ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.selectedThemeId === theme.id ? theme.colors.primary : '#2D5645')
        .margin({ bottom: 5 });

      // 选中标记
      if (this.selectedThemeId === theme.id) {
        Text('✓')
          .fontSize(24)
          .fontColor(theme.colors.primary)
          .fontWeight(FontWeight.Bold);
      }
    }
    .width('100%')
    .height('100%')
    .padding(15)
    .backgroundColor(this.selectedThemeId === theme.id ? '#FFFFFF' : '#FFFFFFCC')
    .borderRadius(20)
    .shadow({
      radius: this.selectedThemeId === theme.id ? 15 : 8,
      color: '#00000030',
      offsetX: 0,
      offsetY: this.selectedThemeId === theme.id ? 6 : 3
    })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.selectedThemeId = theme.id;
    })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
    .scale({
      x: this.selectedThemeId === theme.id ? 1.05 : 1,
      y: this.selectedThemeId === theme.id ? 1.05 : 1
    });
  }
}
