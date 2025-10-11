/**
 * 选取小羊页面
 * 严格按照设计文档实现，使用绝对定位
 */
import { ThemeProvider, THEMES, Theme } from '../theme/ThemeProvider';
import { FontManager } from '../utils/FontManager';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct CharacterSelectScreen {
  @ObjectLink provider: ThemeProvider;
  onConfirm: (themeId: string) => void = () => {};
  onBack: () => void = () => {};
  @State selectedThemeId: string = 'xiyangyang';
  @State fontLoaded: boolean = false;

  aboutToAppear() {
    // 验证字体是否真正可用
    setTimeout(() => {
      hilog.info(0x0000, 'FontCheck', '当前使用字体: %{public}s', FontManager.getFontFamily());
      this.fontLoaded = true;
    }, 1000);
  }
  
  build() {
    Stack() {
      // 背景图片 - 360vp × 792vp
      Image($rawfile('images/background/选择小羊.jpg'))
        .width(360)
        .height(792)
        .objectFit(ImageFit.Cover)
      
      // 容器2 - 主要内容容器
      // W:296vp, H:686vp, Y:53.67vp, X:31.67vp
      Stack() {
        // 标题文本：请选择你的小羊
        // W:296vp, H:118vp, Y:0vp, X:0vp（相对于容器2）
        Text("请选择\n你的小羊")
          .width(296)
          .height(118)
          .fontSize(60)
          .fontWeight(400)
          .lineHeight(65)
          .textAlign(TextAlign.Center)
          .fontColor(Color.Black)
          .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
          .position({ x: 0, y: 0 })
        
        // 容器1 - 小羊选择区域（3行2列布局）
        // W:282vp, H:436vp, Y:155vp, X:7vp（相对于容器2）
        Stack() {
          // 第1行第1列：喜羊羊 - W:115vp, H:116vp, Y:0vp, X:0vp
          this.SheepAvatar('xiyangyang', '喜羊羊', 0, 0)
          
          // 第1行第2列：美羊羊 - X: 282 - 115 = 167
          this.SheepAvatar('meiyangyang', '美羊羊', 0, 167)
          
          // 第2行第1列：懒羊羊 - Y: 115 + 45 = 160
          this.SheepAvatar('lanyangyang', '懒羊羊', 160, 0)
          
          // 第2行第2列：沸羊羊
          this.SheepAvatar('feiyangyang', '沸羊羊', 160, 167)
          
          // 第3行第1列：暖羊羊 - Y: 115 + 45 + 115 + 45 = 320
          this.SheepAvatar('nuanyangyang', '暖羊羊', 320, 0)
          
          // 第3行第2列：慢羊羊
          this.SheepAvatar('manyangyang', '慢羊羊', 320, 167)
        }
        .width(282)
        .height(436)
        .position({ x: 7, y: 155 })
        
        // 确认按钮 - W:190vp, H:58vp, Y:628vp, X:53vp（相对于容器2）
        Stack() {
          // 矩形3 - 白色背景 W:198vp, H:66vp, Y:-4vp, X:-4vp（相对于按钮）
          Column()
            .width(198)
            .height(66)
            .backgroundColor(Color.White)
            .borderRadius(33)
            .border({ width: 2, color: Color.Black, style: BorderStyle.Solid })
            .position({ x: -4, y: -4 })
          
          // 按钮文本 - W:124vp, H:34vp, Y:12vp, X:33vp（相对于按钮）
          Text("确认选择")
            .width(124)
            .height(34)
            .fontSize(31)
            .fontWeight(400)
            .lineHeight(34)
            .textAlign(TextAlign.Center)
            .fontColor(Color.Black)
            .fontFamily(`${FontManager.getFontFamily()}, ${FontManager.getFallbackFont()}`)
            .position({ x: 33, y: 12 })
        }
        .width(190)
        .height(58)
        .position({ x: 53, y: 628 })
        .onClick(() => {
          this.provider.setTheme(this.selectedThemeId);
          this.onConfirm(this.selectedThemeId);
        })
      }
      .width(296)
      .height(686)
      .position({ x: 31.67, y: 53.67 })
    }
    .width(360)
    .height(792)
    .alignContent(Alignment.TopStart)
  }

  @Builder
  SheepAvatar(themeId: string, sheepName: string, y: number, x: number) {
    // 小羊组件 - W:115vp, H:115vp（圆形）
    Stack() {
      // Mask - 圆形头像图片
      Image($rawfile(`images/avatar/${sheepName}.jpg`))
        .width(115)
        .height(115)
        .borderRadius(57.5) // 圆形效果
        .objectFit(ImageFit.Cover)
        .position({ x: 0, y: 0 })
    }
    .width(115)
    .height(115)
    .borderRadius(57.5) // 让容器也是圆形，这样阴影才是圆的
    .clip(true) // 裁剪为圆形
    .position({ x: x, y: y })
    // 选中状态：悬浮 + 阴影效果
    .translate(this.selectedThemeId === themeId ? { y: -8 } : { y: 0 })
    .shadow(this.selectedThemeId === themeId ? {
      radius: 20,
      color: 'rgba(0, 0, 0, 0.4)',
      offsetX: 0,
      offsetY: 8
    } : {
      radius: 0,
      color: Color.Transparent,
      offsetX: 0,
      offsetY: 0
    })
    .scale(this.selectedThemeId === themeId ? { x: 1.05, y: 1.05 } : { x: 1, y: 1 })
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
    .onClick(() => {
      this.selectedThemeId = themeId;
    })
  }
}
